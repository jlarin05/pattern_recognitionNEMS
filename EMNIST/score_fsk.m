function [score, detail] = score_fsk(patterns, iteration)
%this function is used to calculate the recognition accuracy (including the
%recognition accuracy for individual digits) for the PSK ONN

    %the variables need to be created in pattern_recognition.m
    global train_full labels

    %The score is increased by 1 when the match is determined correctly
    score = 0;
    details = zeros(10, 11);
    detail = zeros(10, 3);

    %the delta omega matrix is found
    overlap = generate_overlap_fskbt(patterns);
    for i  = iteration:iteration+9999
        %the data is processed
        train = conv2(train_full(:,:,i), ones(2)/4, 'valid');
        train = train(1:2:end, 1:2:end);
        train = deskew(train);
        train = train/255;
        train = reshape(train, 14*14, 1);
        DoM = zeros(10, 1);

        %the match is found
        for j = 1:10
            [t, x] = FSK(train, patterns(:, j), overlap(:, j), 15); %15
            DoM(j) = x(end);
        end

        [val, ind] = max(DoM);
        if ind == labels(i) + 1
            %if the match is accurate, score is increased by 1
            score = score + 1;
            details (labels(i) + 1, 1) = details(labels(i) + 1, 1) + 1;
        else
            %otherwise, the malrecognised digit is recordered
            details(labels(i) + 1, ind + 1) = details(labels(i) + 1, ind + 1) + 1;
        end
    end
    detail(:, 1) = details(:, 1);
    % the most commonly misidentified digits are found
    [val, ind] = max(details(:, 2:11), [], 2);
    detail(:, 2) = ind;
    detail(:, 3) = val;
end