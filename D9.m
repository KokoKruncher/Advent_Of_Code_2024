clear; clc;

%% Part 1
filename = "D9 Data.txt";
diskMap = readlines(filename);

blocks = decodeDiskMap(diskMap);
compactedBlocks = compactBlocks(blocks);
checksum = calculateChecksum(compactedBlocks);
fprintf("Checksum: %i \n",checksum)



function blocks = decodeDiskMap(diskMap)
% don't join the blocks into single string as fileIDs could have multiple digits!

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



function blocks = compactBlocks(blocks)
locLastFileBlock = find(blocks ~= ".",1,"last");
locFirstFreeSpaceBlock = find(blocks == ".",1,"first");

fprintf("[%s] - Compacting blocks.\n",datetime)
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
fprintf("[%s] - Compacting blocks done. Iterations: %i\n",datetime,nIterations)
end



function checksum = calculateChecksum(compactedBlocks)
assert(numel(compactedBlocks) > 1 && isvector(compactedBlocks));

fileIds = compactedBlocks(compactedBlocks ~= ".");
fileIds = str2double(fileIds);
nFileIds = numel(fileIds);
filePositions = 0:(nFileIds - 1);
multiplicationResult = filePositions.*fileIds;
checksum = sum(multiplicationResult,"all");
end