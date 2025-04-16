function distorted_letter = distort_precise(letter, p)
%This function distorts an array of 1's and -1's, flipping p random pixels
    N = numel(letter);
    distorted_letter = letter;
    idx = randsample(N, p);
    for i = idx
            distorted_letter(i) = -1*letter(i);
    end
end