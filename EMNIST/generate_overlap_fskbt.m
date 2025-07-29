function overlap = generate_overlap_fskbt(patterns)
%the overlap between the patterns is found to create the delta omega matrix
    overlap = zeros(14*14, 10);
    for i = 1:10
        for j = 1:10
            if (i ~= j)
                if degree_of_match(exp(pi*1i*patterns(:, i)), exp(pi*1i*patterns(:, j))) > 0.5
                    overlap(:, j) = overlap(:, j) + abs(patterns(:, i) - patterns(:, j));
                end
            end
        end
    end
end