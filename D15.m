clear; clc;

filename = "D15 Data.txt";
data = readlines(filename);
[grid,instructions] = parseData(data);

%% Part 1
tic
gridSize = size(grid);

dirKeys = ["^" ">" "v" "<"];
dirValues = {[-1 0], [0 1], [1 0], [0 -1]};
direction = dictionary(dirKeys,dirValues);

initialLocationLinearIndx = find(grid == "@");
[location(1),location(2)] = ind2sub(gridSize,initialLocationLinearIndx);

% replace initial location with free space
grid(initialLocationLinearIndx) = ".";

% move the robot and boxes
for instruction = instructions(:)'
    thisDirection = direction{instruction};
    [canMove,locationsToShift] = checkIfCanMove(location,thisDirection,grid,{});

    if ~canMove
        continue
    end
    
    location = location + thisDirection;
    if ~isempty(locationsToShift)
        grid = shift(locationsToShift,thisDirection,grid);
    end
end

% calculate GPS coordinates of the boxes
sumBoxGpsCoordinates = calculateSumGpsCoordinates(grid,"O");

fprintf("Sum of box GPS coordinates: %i\n",sumBoxGpsCoordinates)
toc
%% Functions
function [canMove,locationsToShift] = checkIfCanMove(location,thisDirection,grid,locationsToShift)
nextLocation = location + thisDirection;
nextGridSpot = grid(nextLocation(1),nextLocation(2));

if nextGridSpot == "."
    canMove = true;
elseif nextGridSpot == "O"
    locationsToShift = [locationsToShift, {nextLocation}];
    [canMove,locationsToShift] = checkIfCanMove(nextLocation,thisDirection,grid,locationsToShift);
elseif nextGridSpot == "#"
    canMove = false;
else
    error("Unknown grid spot: %s",nextGridSpot)
end
end



function grid = shift(locationsToShift,thisDirection,grid)
nLocationsToShift = numel(locationsToShift);

% make 1st location into free space
firstLocation = locationsToShift{1};
grid(firstLocation(1),firstLocation(2)) = ".";

% shift boxes by setting all grid spots at new locations to "O"
for i = nLocationsToShift
    thisLocation = locationsToShift{i};
    nextLocation = thisLocation + thisDirection;
    grid(nextLocation(1),nextLocation(2)) = "O";
end
end



function sumGpsCoordinates = calculateSumGpsCoordinates(grid,gridType)
locationsLinearIndx = find(grid == gridType);
[rows,cols] = ind2sub(size(grid),locationsLinearIndx);

distancesFromTopEdge = rows - 1;
distancesFromLeftEdge = cols - 1;
gpsCoordinates = (100*distancesFromTopEdge) + distancesFromLeftEdge;
sumGpsCoordinates = sum(gpsCoordinates,"all");
end



function [grid,instructions] = parseData(data)
indxEmptyLine = find(data == "");

gridString = data(1:indxEmptyLine-1);
gridString = split(gridString,"");
gridString = gridString(:,2:end-1);

% comparisons with strings is slow, so swicth to representing grid objects as numbers
% gridSize = size(gridString);
% grid = nan(gridSize);
% grid(gridString == ".") = 0; % free space
% grid(gridString == "O") = 1; % box
% grid(gridString == "#") = 2; % wall
% assert(~any(isnan(grid),"all"),"Grid has some nan values")

% combine all instructions into one line
instructionsString = data(indxEmptyLine+1:end);
instructionsString = join(instructionsString,"");
instructionsString = split(instructionsString,"");
instructionsString = instructionsString(instructionsString ~= "");

grid = gridString;
instructions = instructionsString;
end