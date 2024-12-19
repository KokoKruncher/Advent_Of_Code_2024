clear; clc;

%% Part 1
filename = "D7 Data.txt";
data = readlines(filename);

% setup parallel pool for brute forcing this shit
nWorkers = 12;
parpool(nWorkers);

[testValueArray,testNumbersArray] = formatData(data);

tic
allowedOperators = ["*" "+"];
bSuccess = false(size(testValueArray));
nTestValues = numel(testValueArray);
parfor iTestValue = 1:nTestValues
    testValue = testValueArray(iTestValue);
    testNumbers = testNumbersArray{iTestValue};
    nTestNumbers = numel(testNumbers);
    nOperators = nTestNumbers - 1;

    operatorPermutations = getPermutations(allowedOperators,nOperators);

    nPermutations = height(operatorPermutations);
    for iPermutation = 1:nPermutations
        operators = operatorPermutations(iPermutation,:);
        evaluatedExpression = evaluateCustomOperators(testNumbers,operators);
        if evaluatedExpression == testValue
            bSuccess(iTestValue) = true;
            break
        end
    end
end
toc

successfulCalibrationResults = testValueArray(bSuccess);
totalCalibrationResult = sum(successfulCalibrationResults,'all');
fprintf("Total calibration results: %i\n", totalCalibrationResult)

%% Part 2

% only need to test equations that were not successful
newTestValueArray = testValueArray(~bSuccess);
newTestNumbersArray = testNumbersArray(~bSuccess);

tic
newAllowedOperators = ["||" "*" "+"];
new_bSuccess = false(size(newTestValueArray));
nTestValues = numel(newTestValueArray);
parfor iTestValue = 1:nTestValues
    testValue = newTestValueArray(iTestValue);
    testNumbers = newTestNumbersArray{iTestValue};
    nTestNumbers = numel(testNumbers);
    nOperators = nTestNumbers - 1;

    operatorPermutations = getPermutations(newAllowedOperators,nOperators);

    % since permutations without "||" were already tested, only test
    % permutations with "||"
    indxContainsConcat = any(contains(operatorPermutations,"||"),2);
    operatorPermutations = operatorPermutations(indxContainsConcat,:);

    nPermutations = height(operatorPermutations);
    for iPermutation = 1:nPermutations
        operators = operatorPermutations(iPermutation,:);
        evaluatedExpression = evaluateCustomOperators(testNumbers,operators);
        if evaluatedExpression == testValue
            new_bSuccess(iTestValue) = true;
            break
        end
    end
end
toc
delete(gcp('nocreate'))

newSuccessfulCalibrationResults = newTestValueArray(new_bSuccess);
newTotalCalibrationResult = sum(newSuccessfulCalibrationResults,'all') + ...
                            totalCalibrationResult;
fprintf("New total calibration results: %i\n", newTotalCalibrationResult)



function permutationMatrix = getPermutations(operators,nPlaces)
arguments
    operators (:,1) {mustBeA(operators,["double", "string"])}
    nPlaces (1,1) double
end
nOperators = numel(operators);
nPermutations = nOperators^nPlaces;

% preallocate matrix
if class(operators) == "double"
    permutationMatrix = nan(nPermutations,nPlaces);
elseif class(operators) == "string"
    permutationMatrix = strings(nPermutations,nPlaces);
else
    error("Elements are of an unsupported class. Pick either double or string.")
end

for iCol = 1:nPlaces
    nRepElem = nOperators^(nPlaces - iCol);
    nRepMat = nOperators^(iCol-1);
    permutationMatrix(:,iCol) = repmat(repelem(operators,nRepElem), nRepMat, 1);
end
end



function [testValueArray,testNumbersArray] = formatData(data)
dataCell = mat2cell(data,ones(size(data)));

% use loop because cellfun treats string arrays like cells of character
% vectors for compatibility which complicates things.
nRows = numel(data);
testValueArray = nan(nRows,1);
testNumbersArray = cell(nRows,1);
for iRow = 1:nRows
    fullString = dataCell{iRow};
    fullStringSplitted = split(fullString,[": "," "]);
    testValueArray(iRow) = str2double(fullStringSplitted(1));
    testNumbersArray{iRow} = fullStringSplitted(2:end)';
end
end



function expression = createExpression(numbers,operators)
arguments
    numbers (1,:) {mustBeA(numbers,"string")}
    operators (1,:) {mustBeA(operators,"string")}
end
assert(numel(numbers) == numel(operators) + 1,"Numbers must be 1 more than operators")

% operations done left to right ignoring BODMAS
% so, put a bracket after each number as well as all the required brackets
% before 1st numbr
numbers = numbers + ")";
nNumbers = numel(numbers);
openingBrackets = join(repmat("(",1,nNumbers),"");
numbers(1) = openingBrackets + numbers(1);

operatorsPadded = [operators ""];
tmp = [numbers', operatorsPadded'];
tmp = tmp';
tmp = tmp(:);
expression = join(tmp(1:end-1),"");
end



function evaluatedExpression = evaluateCustomOperators(testNumbers,operators)
% evaluated the expression from left to right, including the custom
% operator "||" which concatenates two numbers into one
arguments
    testNumbers (1,:) string
    operators (1,:) string
end
testNumbers = str2double(testNumbers);

nOperators = numel(operators);
currentValue = testNumbers(1);
for iOperator = 1:nOperators
    nextNumber = testNumbers(iOperator + 1);
    currentOperator = operators(iOperator);
    switch currentOperator
        case "||"
            % concatenate numbers 
            nDigitsToAdd = numel(num2str(nextNumber));
            currentValue = currentValue*(10^nDigitsToAdd) + nextNumber;
        case "+"
            currentValue = currentValue + nextNumber;
        case "*"
            currentValue = currentValue*nextNumber;
        otherwise
            error("Unknown operator: %s",currentOperator)
    end
end
evaluatedExpression = currentValue;
end