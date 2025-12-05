clear; clc; close all;

joltages = readlines("D03_Data.txt");
joltages = joltages(joltages ~= "");

% joltages = ["987654321111111"; ...
%             "811111111111119"; ...
%             "234234234234278"; ...
%             "818181911112111"];

joltages = str2double(num2cell(char(joltages)));

%% Part 1
maxJoltages = findMaxJoltage(joltages);
outputJoltage = sum(maxJoltages);
fprintf("Output voltage = %i\n", outputJoltage);

%% Functions
function maxJoltages = findMaxJoltage(joltages)
nRows = height(joltages);
[firstDigit, iFirstDigit] = max(joltages(:,1:end-1), [], 2);

remainingDigits = joltages;
for ii = 1:nRows
    remainingDigits(ii, 1:iFirstDigit(ii)) = nan;
end
secondDigit = max(remainingDigits, [], 2, "omitnan");

maxJoltages = firstDigit * 10 + secondDigit;
end