clear; clc; close all;

% file = "D14 Test.txt";
file = "D14 Data.txt";
inputText = readlines(file);
inputText(inputText == "") = [];

initialPositions = str2double(split(extractBetween(inputText, "p=", " v="), ",")).';
velocities = str2double(split(extractAfter(inputText, "v="), ",")).';

%% Part 1
if file == "D14 Data.txt"
    WIDTH = 101;
    HEIGHT = 103;
    SECONDS = 100;
elseif file == "D14 Test.txt"
    WIDTH = 11;
    HEIGHT = 7;
    SECONDS = 100;
else
    error("Unknown file: %s", file)
end

positions = mod(initialPositions + velocities * SECONDS, [WIDTH; HEIGHT]);

middleX = floor(WIDTH / 2);
middleY = floor(HEIGHT / 2);

inQuadrant1 = nnz(positions(1,:) < middleX & positions(2,:) < middleY);
inQuadrant2 = nnz(positions(1,:) > middleX & positions(2,:) < middleY);
inQuadrant3 = nnz(positions(1,:) < middleX & positions(2,:) > middleY);
inQuadrant4 = nnz(positions(1,:) > middleX & positions(2,:) > middleY);

safetyFactor = inQuadrant1 * inQuadrant2 * inQuadrant3 * inQuadrant4;

fprintf("Safety factor = %i\n", safetyFactor);

% plotMap(positions, WIDTH, HEIGHT)

%% Functions
function plotMap(positions, WIDTH, HEIGHT)
rows = positions(2,:) + 1;
cols = positions(1,:) + 1;
nRobots = numel(rows);

robotMap = zeros(HEIGHT, WIDTH);
for ii = 1:nRobots
    thisRow = rows(ii);
    thisCol = cols(ii);
    robotMap(thisRow, thisCol) = robotMap(thisRow, thisCol) + 1;
end
robotMap = char(join(string(robotMap), ""));
robotMap(robotMap == '0') = '.';

disp(robotMap);
disp(" ")
end