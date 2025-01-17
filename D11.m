clear; clc; close all

filename = "D11 Data.txt";
data = readlines(filename);

%% Part 1
stones = str2double(split(data," "))';
% stones = [125 17];

nBlinks = 25;
for iBlink = 1:nBlinks
    stones = blink(stones);
    % disp(iBlink)
end

fprintf("Number of stones: %i\n",numel(stones))
% fprintf("%i ",stones)

%% Functions
function newStones = blink(stones)
nStones = numel(stones);
newStones = [];
for iStone = 1:nStones
    thisStone = stones(iStone);
    
    if thisStone == 0
        newStones(end+1) = 1; %#ok<*AGROW>
        continue
    end
    
    nDigits = numDigits(thisStone);
    if isEven(nDigits)
        % digits drop leading zeros
        replacementStone1 = floor(thisStone/(10^(nDigits/2))); % 1st half of digits
        replacementStone2 = rem(thisStone,10^(nDigits/2)); % 2nd half of digits
        newStones(end+1) = replacementStone1;
        newStones(end+1) = replacementStone2;
        continue
    end

    newStones(end+1) = thisStone*2024;
end
end



function nDigits = numDigits(number)
nDigits = floor(log10(number) + 1);
end



function isNumberEven = isEven(number)
if rem(number,2) == 0
    isNumberEven = true;
else
    isNumberEven = false;
end
end