function DoM = degree_of_match(result, etalon)
%This function calculates the degree of match between two arrays: result
%and etalon
%Constraint: the arrays must have the same length
    N = numel(result);
    DoM = norm(dot(result, etalon)/N);
end