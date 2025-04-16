%This code can be used to generte Hamming Distance vs recognition accuracy
%plots. In its present configuration, it reproduces Fig.5, but it can be
%easily modifed to reproduce other figures as well

%first, read the memorised patterns from the .txt files
fileID = fopen('letters/a.txt', 'r');
char = fscanf(fileID, '%d');
fclose(fileID);
patterns = read_patterns();
score_psk = zeros(1, 24);
score_fskbt = zeros(1, 24);
score_fskrt = zeros(1, 24);

%For the FSKRT networ to function optimally, the frequencise of different
%resontors eed to be changed by different ammounts. Hence, the overlap
%array is generated
overlap = generate_overlap(patterns);


% for Hamming distances 4, 8, ... 96 100 random samples of the given
% Hamming distances are generated. They are then provided as inputs to the
% three networks studied. It is then checked if each network can correctly
% recognise the distorted letter
for i = 1:24
        for j = 1:100
                dist_char = distort_precise(char, i*4);
                [t, output] = PSK_noisy(dist_char, char, 0);
                
                factor = 1/output(1);
                output = factor*output;
                normalised_output = exp(angle(output)*1i);
                DoM1 = degree_of_match(normalised_output, patterns(: , 1));
                DoM2 = zeros(25, 1);
                for l = 2:26
                        DoM2(l-1) = degree_of_match(normalised_output, patterns(: , l));                
                end
                if DoM1 > max(DoM2)
                    score_psk(i) = score_psk(i) + 1;
                end
                [t1, amp1] = FSKBT(dist_char, patterns(:, 1), ones(1, 96), 0, 0, 0);
                amp2 = zeros(25, 1);
                for l = 2:26
                    [t2, amp2] = FSKBT(dist_char, patterns(:, l), ones(1, 96), 0, 0, 0);
                    amp(l-1) = amp2(end);
                end
                if amp1(end) > max(amp)
                    score_fskbt(i) = score_fskbt(i) + 1;
                end

                [t1, DoM1] = FSKRT(dist_char, patterns(:, 1), 12.5, overlap(:, 1), 4.5, 0, 0);
                DoM = zeros(25, 1);
                for l = 2:26
                     [t2, DoM2] = FSKRT(dist_char, patterns(:, l), 12.5, overlap(:, l), 4.5, 0, 0);
                     DoM(l-1) = DoM2(end);
                end
                if  (DoM1 > 0.20) & (max(DoM) < 0.20)
                     score_fskrt(i) = score_fskrt(i) + 1;
                end
        end
        
    
end

%normalise the data
score_psk = score_psk/100;
score_fskbt = score_fskbt/100;
score_fskrt = score_fskrt/100;

%display the data
f = figure();
x = linspace(4, 48, 24);
hold on
scatter(x, score_psk, 'x')
scatter(x, score_fskbt, 'x')
scatter(x, score_fskrt, 'x')
hold off

title('Recognition accuracy vs Hmming Distance')
ylabel('Recognition Accuracy')
xlabel('Hamming Distance')
legend(["PSK", "FSKBT", "FSKRT"])