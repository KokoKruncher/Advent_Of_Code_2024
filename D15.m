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

%% Part 2
newGrid = createNewGrid(grid,initialLocationLinearIndx);
newGridSize = size(newGrid);

initialLocationLinearIndx = find(newGrid == "@");
[location(1),location(2)] = ind2sub(newGridSize,initialLocationLinearIndx);

newGrid(initialLocationLinearIndx) = ".";

for instruction = instructions(:)'
    thisDirection = direction{instruction};
    [canMove,locationsToShift] = checkIfCanMove2(location,thisDirection,newGrid,{});
end

%% Functions
function [canMove,locationsToShift] = checkIfCanMove(location,thisDirection,grid, ...
    locationsToShift)
nextLocation = location + thisDirection;
nextGridSpot = grid(nextLocation(1),nextLocation(2));

if nextGridSpot == "."
    canMove = true;
elseif nextGridSpot == "O"
    % recurse over all boxes in front of robot
    locationsToShift = [locationsToShift, {nextLocation}];
    [canMove,locationsToShift] = checkIfCanMove(nextLocation,thisDirection, ...
        grid,locationsToShift);
elseif ismember(nextGridSpot,["[" "]"])
    % recursively check connected boxes
    [locationsToShift,canMove] = checkConnectedBoxes(nextLocation,thisDirection,grid,nextGridSpot,{});
elseif nextGridSpot == "#"
    canMove = false;
else
    error("Unknown grid spot: %s",nextGridSpot)
end
end



function [boxLocations,canMove] = checkConnectedBoxes(location,robotDirection,grid,gridSpot,boxLocations)
thisBoxLocations = {location};

isRobotGoingEastWest = all(robotDirection == [0 1]) || all(robotDirection == [0 -1]);
if isRobotGoingEastWest
    % robot travelling east or west, other part of the box is one step ahead
    newBoxLocation = location + robotDirection;
elseif gridSpot == "["
    % robot travelling north or south. "]" is located east of here.
    newBoxLocation = location + [0 1];
elseif gridSpot == "]"
    % robot travelling north or south. "[" is located west of here.
    newBoxLocation = location + [0 -1];
else
    error("Unknown condition.")
end
thisBoxLocations = [thisBoxLocations, {newBoxLocation}];
boxLocations = [boxLocations, thisBoxLocations];

% which locations ahead of box to check
if isRobotGoingEastWest
    locationsToCheck = {location + 2*thisDirection};
else
    locationsToCheck = cellfun(@(x) x + robotDirection,thisBoxLocations, ...
        'UniformOutput',false);
end

% check locations ahead
canMove = true;
nLocationsToCheck = numel(locationsToCheck);
for i = 1:nLocationsToCheck
    if canMove == false
        break
    end

    locationToCheck = locationsToCheck(i);
    gridSpotToCheck = grid(locationToCheck(1),locationToCheck(2));
    if ismember(gridSpotToCheck,["[" "]"])
        % recursively check all boxes ahead
        [boxLocations,canMove] = checkConnectedBoxes(locationToCheck,robotDirection,grid,gridSpotToCheck,boxLocations);
        continue
    end
    
    % if not a box, check if wall or free space
    [canMove,~] = checkIfCanMove(locationToCheck,robotDirection,grid,boxLocations);
end
end



% function newDirection = rotate90DegClockwise(direction,n)
% rotationMatrix = [0, 1; -1, 0];
% newDirection = ((rotationMatrix^n)*(direction'))';
% end



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



function newGrid = createNewGrid(grid,initialLocationLinearIndx)
grid(initialLocationLinearIndx) = "@";
newGrid = join(grid,"");

newGrid = replace(newGrid,"#","##");
newGrid = replace(newGrid,"O","[]");
newGrid = replace(newGrid,".","..");
newGrid = replace(newGrid,"@","@.");

newGrid = split(newGrid,"");
newGrid = newGrid(:,2:end-1);
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