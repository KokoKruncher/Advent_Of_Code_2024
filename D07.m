clear; clc; close all;

manifold = readlines("D07_Data.txt");
manifold = manifold(manifold ~= "");

%% Part 1
manifold = char(manifold);
isSplitterArray = manifold == '^';

isBeam = manifold == 'S';
isBeam = isBeam(1,:);

nRows = height(manifold);
nColumns = width(manifold);
nHitsTotal = 0;
for ii = 2:nRows
    isSplitter = isSplitterArray(ii,:);
    isHit = isSplitter & isBeam;

    if ~any(isHit)
        continue
    end

    nHits = nnz(isHit);
    nHitsTotal = nHitsTotal + nHits;

    iHit = find(isHit);
    iNewBeam =  [iHit - 1, iHit + 1];
    iNewBeam = iNewBeam(iNewBeam >= 1 & iNewBeam <= nColumns);

    isBeam(isHit) = false;
    isBeam(iNewBeam) = true;
end

fprintf("Number of times the beam will be split = %i\n", nHitsTotal);