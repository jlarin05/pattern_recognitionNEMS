function patterns = read_patterns()
%This function reads the arrays coddifying letters to be memorized from the
%.txt files
%The outputis stored in a 96x26 matrix
%Each column stores one letter
    i = 1;
    patterns = zeros(96, 26);
    for char = 'a':'z'
        file_name = append('letters/', append(char, '.txt'));
        fileID = fopen(file_name, "r");
        patterns(:, i) = fscanf(fileID, '%d');
        fclose(fileID);
        i = i + 1;
    end
end