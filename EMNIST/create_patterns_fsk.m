function patterns = create_patterns_fsk()   
    %this function creates the patterns that are memorised by the FSK ONN

    patterns = zeros(14*14, 10);
    L=load("emnist-digits.mat");
    data_full = reshape(double(L.dataset.train.images.'), 28, 28, []);
    labels = L.dataset.train.labels;
    for j = 0:9
        count = 0;
        %the count variable is used to normalise the patterns

        for i = 1:24000
            if labels(i) == j
                %Note that for the sake of a better deskewing, it takes
                %place after the data reduction stage; this required a
                %modification of the deskew function (see the comment there)

                %the image size is reduced
                data = conv2(data_full(:,:,i), ones(2)/4, 'valid');
                data = data(1:2:end, 1:2:end);
                %the images are deskewed
                data = deskew(data);
                %the image matrix is reshaped into a vector
                data = reshape(data, 14*14, 1);
                patterns(:, j+1) = patterns(:, j+1) + data;
                count = count + 1;
            end
        end
        %the patterns are normalised to lie between 0 and 1
        patterns(:, j+1) = patterns(:, j+1)/(count*255);
    end
end
