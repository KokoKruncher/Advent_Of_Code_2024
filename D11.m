% to nBlinks = 40
% original: long af
% after vectorisation: 20s, 

clear; clc; close all

filename = "D11 Data.txt";
data = readlines(filename);

%% Part 1
stones = str2double(split(data," "))';
% stones = [125 17];
% stones = [0 1 10 99 999];
tic
nBlinks = 40;
for iBlink = 1:nBlinks
    stones = blink(stones);
    disp(iBlink)
end
toc
fprintf("Number of stones: %i\n",numel(stones))
% fprintf("%i ",stones)

%%

% a = [1 10 100 1000 10000];
% numDigits(a)
% isEven(numDigits(a))

%% Functions
function newStones = blink(stones)
nStones = numel(stones);

nDigitsAllStones = numDigits(stones);
isEvenNumDigits = isEven(nDigitsAllStones);
% disp(nStones)

newStones = [];
for iStone = 1:nStones
    thisStone = stones(iStone);
    
    if thisStone == 0
        newStones(end+1) = 1; %#ok<*AGROW>
        continue
    end
    
    if isEvenNumDigits(iStone)
        % 1st half of digits
        nDigitsThisStone = nDigitsAllStones(iStone);
        
        % 2nd half of digits
        replacementStone1 = floor(thisStone/(10^(nDigitsThisStone/2))); 
        replacementStone2 = rem(thisStone,10^(nDigitsThisStone/2));

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



function areNumbersEven = isEven(numbers)
areNumbersEven = rem(numbers,2) == 0;
end