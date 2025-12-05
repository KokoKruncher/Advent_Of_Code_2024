clear; clc; close all;

allIdString = readlines("D02_Data.txt");
allIdString = allIdString(allIdString ~= "");

% allIdString = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";

%% Part 1
% Perform checks in numbers world to ignore leading zeros
idRanges = split(allIdString, ",");
idRanges = str2double(split(idRanges, "-"));

ids = arrayfun(@(min, maxId) (min:maxId).', idRanges(:,1), idRanges(:,2), 'UniformOutput', false);
ids = vertcat(ids{:});

invalidIds = findIdsRepeatedTwice(ids);
sumInvalidIds = sum(invalidIds);

fprintf("Sum of invalid IDs: %i\n", sumInvalidIds)

%% Functions

function idsRepeatedTwice = findIdsRepeatedTwice(ids)
% Odd number of digits can't have twice repeated pattern
nDigits = floor(log10(ids) + 1);
isCandidate = isEven(nDigits);

ids = ids(isCandidate);
nDigits =  nDigits(isCandidate);

lastHalf = mod(ids, 10.^(nDigits/2));
firstHalf = (ids - lastHalf) ./ (10.^(nDigits/2));
isRepeatedTwice = firstHalf == lastHalf;

idsRepeatedTwice = ids(isRepeatedTwice);
end


function TF = isEven(n)
TF = mod(n, 2) == 0;
end