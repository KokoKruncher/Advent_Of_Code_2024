clear; clc;

%% Part 1
filename = "D9 Data.txt";
diskMap = readlines(filename);

blocks = decodeDiskMap(diskMap);
compactedBlocksIndividual = compactDiskIndividualFileBlocks(blocks);
checksumIndividualMethod = calculateChecksum(compactedBlocksIndividual);
fprintf("Checksum (individual method): %i \n\n",checksumIndividualMethod)

%% Part 2
compactedBlocksWhole = compactDiskWholeFile(blocks);
checksumWholeMethod = calculateChecksum(compactedBlocksWhole);
fprintf("Checksum (whole method): %i \n\n",checksumWholeMethod)



function blocks = decodeDiskMap(diskMap)
% don't join the blocks into single string as fileIDs could have multiple digits!

fprintf("[%s] - Decoding disk map.\n",datetime)
diskMap = splitStringIntoArray(diskMap);
diskMap = str2double(diskMap);

nDiskMapElements = numel(diskMap);
blocks = cell(size(diskMap));

% handle files
fileId = 0;
for i = 1:2:nDiskMapElements
    nBlocksThisFile = diskMap(i);
    blocks{i} = repelem(string(fileId),1,nBlocksThisFile);
    fileId = fileId + 1;
end

% handle free spaces
for i = 2:2:nDiskMapElements
    nBlocksThisFreeSpace = diskMap(i);
    blocks{i} = repelem(".",1,nBlocksThisFreeSpace);
end

indxEmptyStrings = cellfun(@isempty,blocks);
blocks(indxEmptyStrings) = [];

blocks = [blocks{:}];
end



function splitString = splitStringIntoArray(str)
assert(numel(str) == 1);
splitString = split(str,"")';
splitString = splitString(2:end-1);
end



function blocks = compactDiskIndividualFileBlocks(blocks)
locLastFileBlock = find(blocks ~= ".",1,"last");
locFirstFreeSpaceBlock = find(blocks == ".",1,"first");

fprintf("[%s] - Compacting disk (individual file blocks).\n",datetime)
nIterations = 0;
while locLastFileBlock > locFirstFreeSpaceBlock
    nIterations = nIterations + 1;
    lastFileBlock = blocks(locLastFileBlock);
    firstFreeSpaceBlock = blocks(locFirstFreeSpaceBlock);

    blocks(locFirstFreeSpaceBlock) = lastFileBlock;
    blocks(locLastFileBlock) = firstFreeSpaceBlock;

    locLastFileBlock = find(blocks ~= ".",1,"last");
    locFirstFreeSpaceBlock = find(blocks == ".",1,"first");
end
fprintf("[%s] - Compacting disk done. Iterations: %i\n",datetime,nIterations)
end



function blocks = compactDiskWholeFile(blocks)
fprintf("[%s] - Compacting disk (whole file blocks).\n",datetime)
fileBlocks = blocks(blocks ~= ".");
fileIdArray = unique(str2double(fileBlocks)); % returns sorted array (ascending)
fileIdArray = fileIdArray(end:-1:1); % sort in descending order
fileIdArray = string(fileIdArray);

% create struct to store more info together
nBlocks = numel(blocks);
blocksCell = num2cell(blocks);
BlockData = struct;
[BlockData(1:nBlocks).block] = blocksCell{:};
[BlockData([BlockData.block] == ".").type] = deal("Free Space");
[BlockData([BlockData.block] ~= ".").type] = deal("File");


% delete this line
% fileIdArray = fileIdArray(1:10);
for thisFileId = fileIdArray(:)'
    % disp(thisFileId) % delete this line
    indxThisFileId = [BlockData.block] == thisFileId;
    nBlocksThisFileId = sum(indxThisFileId,"all");
    firstLocThisFileId = find(indxThisFileId,1,"first");

    indxFreeSpace = [BlockData.type] == "Free Space";
    [startLocsFreeSpace,~,nFreeSpaces] = groupLogicalIndices(indxFreeSpace);
    
    indxValidFreeSpaceGroups = startLocsFreeSpace < firstLocThisFileId & ...
                               nFreeSpaces >= nBlocksThisFileId;

    if ~any(indxValidFreeSpaceGroups)
        continue
    end

    startLocsValidFreeSpace = startLocsFreeSpace(indxValidFreeSpaceGroups);
    
    startLocChosenFreeSpace = startLocsValidFreeSpace(1); % choose leftmost one
    stopLocChosenFreeSpace = startLocChosenFreeSpace + nBlocksThisFileId - 1;

    % swap
    fileBlocksToSwap = BlockData(indxThisFileId);
    freeSpaceBlocksToSwap = BlockData(startLocChosenFreeSpace:stopLocChosenFreeSpace);
    BlockData(startLocChosenFreeSpace:stopLocChosenFreeSpace) = fileBlocksToSwap;
    BlockData(indxThisFileId) = freeSpaceBlocksToSwap;
end
blocks = [BlockData.block];
fprintf("[%s] - Compacting disk done. Iterations: %i\n",datetime,numel(fileIdArray))
end



function [startLocs,stopLocs,nElements] = groupLogicalIndices(indx)
arguments
    indx (1,:) logical
end
startLocs = find(diff([false indx]) == 1);
stopLocs = find(diff([indx false]) == -1);
nElements = stopLocs - startLocs + 1;
end



function checksum = calculateChecksum(blocks)
assert(numel(blocks) > 1 && isvector(blocks));

blocks(blocks == ".") = "0"; % skip free space blocks
blocks = str2double(blocks);
nBlocks = numel(blocks);
blockPositions = 0:(nBlocks - 1);
multiplicationResult = blockPositions.*blocks;
checksum = sum(multiplicationResult,"all");
end