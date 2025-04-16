%For the FSKRT networ to function optimally, the frequencise of different
%resontors need to be changed by different ammounts. This function generates
%the overlap vector: for each layers, the closest patterns to the pattern
%memorised by that layer are found. To do so, we find whether the layer
%keeps oscillating, if this pattern is provided as an input (with slightly reduced value of delta omega)
%If it does, then the oscillators corresponding to the non-matching pixels
%of thse two patterns will experience a greater frequency change. The
%output is stored in an array, which is then normalised
function overlap = generate_overlap(patterns)
    pre_overlap = zeros(96, 26);
    for i = 1:26
        for j = 1:26
            if (i ~= j)
                [t, x] = FSKRT(patterns(:, i), patterns(:, j), 10, ones(96, 1), 0, 0, 0);
                if max(x(end-250:end)) > 0.20
                    pre_overlap(:, j) = pre_overlap(:, j) + (patterns(:, i) ~= patterns(:, j));
                end
            end
        end
    end
    %It remains to normalise the produced array
    overlap = pre_overlap;
    for i = 1:26
        if max(pre_overlap(:, i) > 0)
            overlap(:, i) = overlap(:, i)/(max(pre_overlap(:, i)));
        end
    end
end