clear; clc; close all;

coords = readlines("D09_Data.txt");
coords = coords(coords ~= "");
coords = split(coords, ",");
coords = str2double(coords);

%% Part 1
iHull = convhull(coords(:,1), coords(:,2));
iHull = iHull(1:end-1);

candidates = coords(iHull,:);
nCandidates = height(candidates);

pairs = nchoosek(1:nCandidates, 2);
areas = squareAreas(candidates(pairs(:,1),:), candidates(pairs(:,2),:));
maxArea = max(areas);

fprintf("Max area = %i\n", maxArea);

%% Functions
function areas = squareAreas(startCorners, endCorners)
dx = abs(startCorners(:,1) - endCorners(:,1));
dy = abs(startCorners(:,2) - endCorners(:,2));
areas = (dx + 1) .* (dy + 1);
end

