clear; clc; close all;

problems = readlines("D06_Data.txt");
problems = problems(problems ~= "");
problems = strip(problems);
problems = split(problems);

numbers = str2double(problems(1:end-1,:));
operators = problems(end,:);

%% Part 1
nProblems = width(problems);
results = nan(1, nProblems);

for ii = 1:nProblems
    thisOperator = operators(ii);
    switch thisOperator
        case "+"
            results(ii) = sum(numbers(:,ii));
        case "*"
            results(ii) = prod(numbers(:,ii));
        otherwise
            error("Unknown operator: %s", thisOperator);
    end
end

grandTotal = sum(results);
fprintf("Grand total = %i\n", grandTotal);
