%this is the main function, which can be used to find the recognition
%accuracy
L=load("emnist-digits.mat");
global train_full labels
train_full = reshape(double(L.dataset.test.images.'), 28, 28, []);
labels = L.dataset.test.labels;

patterns = create_patterns_fsk();
[score, detail] = fitness_score_fsk(patterns, 1)
