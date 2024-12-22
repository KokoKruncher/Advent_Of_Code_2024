clear; clc;

filename = "D22 Data.txt";
secretNumbersInitial = readmatrix(filename);
% secretNumbersInitial = [1; 2; 3; 20204];

%% Part 1
tic
nTimeToEvolve = 2000;
secretNumbersEvolved = evolve(secretNumbersInitial,nTimeToEvolve);

sumNewSecretNumbers = sum(secretNumbersEvolved(:,end),"all");
toc

fprintf("Sum of new secret numbers = %i\n\n",sumNewSecretNumbers)

%% Part 2

tic
% each buyer has a row of prices
prices = mod([secretNumbersInitial, secretNumbersEvolved],10);
priceChanges = diff(prices,1,2);

windowLength = 4;
possibleWindows = createWindows(priceChanges,windowLength);

nRows = height(priceChanges);
nCols = width(priceChanges);
nPossibleWindows = numel(possibleWindows);
maxPrice = 0;
sequenceMaxPrice = nan;
for iWindow = 1:1000
    % disp(iWindow)
    window = possibleWindows{iWindow};
    [thisWindowPrice,cannotBeMoreThanMax] = getPrice(window,prices,priceChanges,nRows, ...
        windowLength,maxPrice);

    if cannotBeMoreThanMax
        continue
    end
    
    if thisWindowPrice > maxPrice
        maxPrice = thisWindowPrice;
        sequenceMaxPrice = window;
    end
end
toc

fprintf("Max bananas: %i\n",maxPrice)

%% Functions
function out = mix(secretNumber,value)
out = bitxor(secretNumber,value);
end



function out = prune(secretNumber)
out = mod(secretNumber,16777216);
end



function secretNumbersEvolved = evolve(secretNumbers,nTimesToEvolve)
arguments
    secretNumbers (:,1) double
    nTimesToEvolve (1,1) double
end
nBuyers = length(secretNumbers);
secretNumbersEvolved = nan(nBuyers,nTimesToEvolve);

for i = 1:nTimesToEvolve
    val = secretNumbers.*64;
    secretNumbers = mix(secretNumbers,val);
    secretNumbers = prune(secretNumbers);

    val = floor(secretNumbers./32);
    secretNumbers = mix(secretNumbers,val);

    val = secretNumbers.*2048;
    secretNumbers = mix(secretNumbers,val);
    secretNumbers = prune(secretNumbers);

    secretNumbersEvolved(:,i) = secretNumbers;
end
end



function uniqueWindows = createWindows(priceChanges,windowLength)
nRows = height(priceChanges);
nCols = width(priceChanges);
nMaxPossibleWindowsPerRow = (nCols - windowLength + 1);
nMaxPossibleWindows = nMaxPossibleWindowsPerRow*nRows;

possibleWindows = cell(1,nMaxPossibleWindows);
iPossibleWindows = 1;
for iRow = 1:nRows
    row = priceChanges(iRow,:);
    for iCol = 1:nMaxPossibleWindowsPerRow
        window = row(iCol:(iCol + windowLength - 1));
        possibleWindows{iPossibleWindows} = window;
        iPossibleWindows = iPossibleWindows + 1;
    end
end

% find unique windows only (40k out of 4.5 mil -> 100x smaller)
possibleWindows = vertcat(possibleWindows{:});
uniqueWindows = unique(possibleWindows,'rows');

% convert back to cell array
uniqueWindows = mat2cell(uniqueWindows,ones(height(uniqueWindows),1),windowLength);
end



function [currentPrice,cannotBeMoreThanMax] = getPrice(window,prices,priceChanges, ...
    nRows,windowLength,currentMaxPrice)
indxFoundSequence = ismember(priceChanges,window);
doesRowHaveSequence = any(indxFoundSequence,2);

currentPrice = nan;
cannotBeMoreThanMax = false;
nRowsWithSequence = sum(doesRowHaveSequence);
if (nRowsWithSequence*9) <= currentMaxPrice
    cannotBeMoreThanMax = true;
    return
end

currentPrice = 0;
for iRow = 1:nRows
    if ~doesRowHaveSequence(iRow)
        continue
    end
    
    thisRowIndxFoundSequence = indxFoundSequence(iRow,:);
    locSequence = find(thisRowIndxFoundSequence,windowLength,"first");
    locPrice = locSequence(end);
    thisPrice = prices(locPrice + 1);
    
    currentPrice = currentPrice + thisPrice;
end
end