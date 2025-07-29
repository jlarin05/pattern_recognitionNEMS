function [score, detail] = score(patterns, iteration)
%this function is used to calculate the recognition accuracy (including the
%recognition accuracy for individual digits) for the PSK ONN

    %the variables need to be created in pattern_recognition.m
    global train_full labels
    %coupling is calculated
    coupling = calculate_coupling(patterns);
    %The score is increased by 1 when the match is determined correctly
    score = 0;
    details = zeros(10, 11);
    detail = zeros(10, 3);
    for i  = iteration:iteration+99
        %the data is processed
        train = conv2(train_full(:, :, i), ones(2)/4, 'valid');
        train = train(1:2:end, 1:2:end);
        train = deskew(train);
        train = train/255;
        train = pi*train;
        train = exp(1i*train);
        train = reshape(train, 14*14, 1);

        %the DoM is calculated
        DoM = PSK(train, patterns(:, labels(i) + 1), coupling);

        if DoM > 0.95
            %if the match is found, score is increased by 1
            score = score + 1;
            details (labels(i) + 1, 1) = details(labels(i) + 1, 1) + 1;
        else
            %otherwise, the malrecognised digit is found
            DoMs = zeros(10, 1);
            for j = 1:10
                if labels(i) + 1 ~= j
                    DoMs(j) = PSK(train, patterns(:,  j), coupling);
                end
            end
            [val, ind] = max(DoMs);
            details(labels(i) + 1, ind + 1) = details(labels(i) + 1, ind + 1) + 1;
        end 
    end
    detail(:, 1) = details(:, 1);
    % the most commonly misidentified digits are found
    [val, ind] = max(details(:, 2:11), [], 2);
    detail(:, 2) = ind;
    detail(:, 3) = val;
end