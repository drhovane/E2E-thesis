close all
clear

fig = 1;

%%
projectpath = 'C:\Users\username\Documents\E2E-thesis';     %full path to E2E-thesis project folder
addpath([projectpath, '\Trained\Testing\Evaluation\Matlab'])

% directory definition !! replace with your own model directories !!
DataDirPretrained = [projectpath, '\Pretrained\testing\eval_outputs\dtw'];
DataDirFull = [projectpath, '\Trained\Testing\Evaluation\Matlab\full\eval_outputs\dtw'];
DataDirHalf = [projectpath, '\Trained\Testing\Evaluation\Matlab\half\eval_outputs\dtw'];
DataDirQuarter = [projectpath, '\Trained\Testing\Evaluation\Matlab\quarter\eval_outputs\dtw'];
DataDirEighth = [projectpath, '\Trained\Testing\Evaluation\Matlab\eighth\eval_outputs\dtw'];
DataDirSixteenth = [projectpath, '\Trained\Testing\Evaluation\Matlab\sixteenth\eval_outputs\dtw'];
DataDirDifferent = [projectpath, '\Trained\Testing\Evaluation\Matlab\different_speech_compare\dtw'];

% filenames
fileNamePretrained = 'cumulative_distances_pretrained.mat';
fileNameFull = 'cumulative_distances_full.mat';
fileNameHalf = 'cumulative_distances_half.mat';
fileNameQuarter = 'cumulative_distances_quarter.mat';
fileNameEighth = 'cumulative_distances_eighth.mat';
fileNameSixteenth = 'cumulative_distances_sixteenth.mat';
fileNameDifferent = 'cumulative_distances_different.mat';

% Načtení souborů do proměnných
pretrained = load(fullfile(DataDirPretrained, fileNamePretrained));
full = load(fullfile(DataDirFull, fileNameFull));
half = load(fullfile(DataDirHalf, fileNameHalf));
quarter = load(fullfile(DataDirQuarter, fileNameQuarter));
eighth = load(fullfile(DataDirEighth, fileNameEighth));
sixteenth = load(fullfile(DataDirSixteenth, fileNameSixteenth));
different = load(fullfile(DataDirDifferent, fileNameDifferent));

%%
% Výpočet mediánu, kvartilů a percentilů
medianPretrained = median(pretrained.cumulative_distances);
medianFull = median(full.cumulative_distances)
medianHalf = median(half.cumulative_distances)
medianQuarter = median(quarter.cumulative_distances)
medianEighth = median(eighth.cumulative_distances)
medianSixteenth = median(sixteenth.cumulative_distances)
medianDifferent = median(different.cumulative_distances)

%%
q1Pretrained = prctile(pretrained.cumulative_distances, 25); % 1st Quartile
q3Pretrained = prctile(pretrained.cumulative_distances, 75); % 3rd Quartile

q1Full = prctile(full.cumulative_distances, 25); % 1st Quartile
q3Full = prctile(full.cumulative_distances, 75); % 3rd Quartile

q1Half = prctile(half.cumulative_distances, 25); % 1st Quartile
q3Half = prctile(half.cumulative_distances, 75); % 3rd Quartile

q1Quarter = prctile(quarter.cumulative_distances, 25); % 1st Quartile
q3Quarter = prctile(quarter.cumulative_distances, 75); % 3rd Quartile

q1Eighth = prctile(eighth.cumulative_distances, 25); % 1st Quartile
q3Eighth = prctile(eighth.cumulative_distances, 75); % 3rd Quartile

q1Sixteenth = prctile(sixteenth.cumulative_distances, 25); % 1st Quartile
q3Sixteenth = prctile(sixteenth.cumulative_distances, 75); % 3rd Quartile

q1Different = prctile(different.cumulative_distances, 25); % 1st Quartile
q3Different = prctile(different.cumulative_distances, 75); % 3rd Quartile

%%
percentile5Pretrained = prctile(pretrained.cumulative_distances, 5); % 5th Percentile
percentile95Pretrained = prctile(pretrained.cumulative_distances, 95); % 95th Percentile

percentile5Full = prctile(full.cumulative_distances, 5); % 5th Percentile
percentile95Full = prctile(full.cumulative_distances, 95); % 95th Percentile

percentile5Half = prctile(half.cumulative_distances, 5); % 5th Percentile
percentile95Half = prctile(half.cumulative_distances, 95); % 95th Percentile

percentile5Quarter = prctile(quarter.cumulative_distances, 5); % 5th Percentile
percentile95Quarter = prctile(quarter.cumulative_distances, 95); % 95th Percentile

percentile5Eighth = prctile(eighth.cumulative_distances, 5); % 5th Percentile
percentile95Eighth = prctile(eighth.cumulative_distances, 95); % 95th Percentile

percentile5Sixteenth = prctile(sixteenth.cumulative_distances, 5); % 5th Percentile
percentile95Sixteenth = prctile(sixteenth.cumulative_distances, 95); % 95th Percentile

percentile5Different = prctile(different.cumulative_distances, 5); % 5th Percentile
percentile95Different = prctile(different.cumulative_distances, 95); % 95th Percentile



%%
% Vykreslení histogramů
figure(fig)
fig = fig+1;
histogram(pretrained.cumulative_distances, 100, 'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(pretrained.cumulative_distances);
xline(medianPretrained)
plot(xi, f,'Color', 'r')
title('Histogram - Pretrained')
xlabel('Hodnoty')
ylabel('Frekvence')

figure(fig)
fig = fig+1;
histogram(full.cumulative_distances, 100, 'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(full.cumulative_distances);
xline(medianFull)
plot(xi, f,'Color', 'r')
title('Histogram - Full Resolution')
xlabel('Hodnoty')
ylabel('Frekvence')

figure(fig)
fig = fig+1;
histogram(half.cumulative_distances, 50, 'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(half.cumulative_distances);
plot(xi, f,'Color', 'r')
title('Histogram - Half Resolution')
xlabel('Hodnoty')
ylabel('Frekvence')
hold off

figure(fig)
fig = fig+1;
histogram(quarter.cumulative_distances, 50,'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(quarter.cumulative_distances);
plot(xi, f,'Color', 'r')
title('Histogram - Quarter Resolution')
xlabel('Hodnoty')
ylabel('Frekvence')
hold off

figure(fig)
fig = fig+1;
histogram(eighth.cumulative_distances, 50,'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(quarter.cumulative_distances);
plot(xi, f,'Color', 'r')
title('Histogram - Eighth Resolution')
xlabel('Hodnoty')
ylabel('Frekvence')
hold off

figure(fig)
fig = fig+1;
histogram(sixteenth.cumulative_distances, 50,'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(sixteenth.cumulative_distances);
plot(xi, f,'Color', 'r')
title('Histogram - Sixteenth Resolution')
xlabel('Hodnoty')
ylabel('Frekvence')
hold off

figure(fig)
fig = fig+1;
histogram(different.cumulative_distances, 100, 'Normalization', 'pdf')
hold on
[f, xi] = ksdensity(different.cumulative_distances);
xline(medianFull)
plot(xi, f,'Color', 'r')
title('Histogram - Different Samples')
xlabel('Hodnoty')
ylabel('Frekvence')
%%
figure(fig)
fig = fig + 1;

% Vypočítání a vykreslení KDE pro 'full'
[f_full, xi_full] = ksdensity(full.cumulative_distances, "NumPoints", 500);
plot(xi_full, f_full, 'Color', "#0072BD", 'LineWidth', 1.5)
hold on
%xline(median(full.cumulative_distances), '--r', 'Median', 'LabelHorizontalAlignment', 'left');

% Vypočítání a vykreslení KDE pro 'half'
[f_half, xi_half] = ksdensity(half.cumulative_distances, "NumPoints", 500);
plot(xi_half, f_half, 'Color', "#77AC30", 'LineWidth', 1.5)

% Vypočítání a vykreslení KDE pro 'pretrained'
[f_pretrained, xi_pretrained] = ksdensity(pretrained.cumulative_distances, "NumPoints", 500);
plot(xi_pretrained, f_pretrained, 'LineStyle', ':', 'Color', "#D95319", 'LineWidth', 1.5)
hold on

% Vypočítání a vykreslení KDE pro 'quarter'
[f_quarter, xi_quarter] = ksdensity(quarter.cumulative_distances, "NumPoints", 500);
plot(xi_quarter, f_quarter, 'Color', "#A2142F", 'LineWidth', 1.5)

% Vypočítání a vykreslení KDE pro 'eighth'
[f_eighth, xi_eighth] = ksdensity(eighth.cumulative_distances, "NumPoints", 500);
plot(xi_eighth, f_eighth, 'Color', "#4DBEEE", 'LineWidth', 1.5)

% Vypočítání a vykreslení KDE pro 'sixteenth'
[f_sixteenth, xi_sixteenth] = ksdensity(sixteenth.cumulative_distances, "NumPoints", 500);
plot(xi_sixteenth, f_sixteenth, 'Color', "#EDB120", 'LineWidth', 1.5)

% Vypočítání a vykreslení KDE pro 'different'
[f_different, xi_different] = ksdensity(different.cumulative_distances, "NumPoints", 500);
plot(xi_different, f_different, 'k:', 'LineWidth', 1.5)

% Nastavení vzhledu grafu
title('Distribution of Cumulative Distances')
xlabel('Cumulative Distances')
ylabel('Probability Density')
legend('LJSpeech100', 'LJSpeech50', 'Pretrained', 'LJSpeech25', 'LJSpeech12', 'LJSpeech6', 'Different Samples')
hold off
xlim([0.03, 0.73])
set(gcf, 'Position', [100,100,500,300])

%%
% Vytvoření datové matice pro boxplot
data = [pretrained.cumulative_distances', full.cumulative_distances', half.cumulative_distances', ...
        quarter.cumulative_distances', eighth.cumulative_distances', sixteenth.cumulative_distances', different.cumulative_distances'];

% Popisky pro jednotlivé boxploty
labels = {'Pretrained', 'LJSpeech100', 'LJSpeech50', 'LJSpeech25', 'LJSpeech12', 'LJSpeech6', 'Different Samples'};

% Vykreslení boxplotu
figure
h = boxplot(data, 'Labels', labels, 'Whisker', 1.5, 'Symbol', '');
colors =  {'#A2142F'; '#0072BD'; '#0072BD'; '#0072BD'; '#0072BD'; '#0072BD'; '#A2142F'};

boxes = findobj(gca, 'Tag', 'Box'); % Najde všechny boxploty
for i = 1:length(colors)
    patch = boxes(i);
    set(patch, 'Color', colors{i}); % Nastavení barvy pro každý boxplot
end

% Nastavení vzhledu grafu
title('Boxplots of Cumulative Distances')
ylabel('Cumulative Distances')
ylim([0.05 0.64]) % Nastavení rozsahu osy Y, pokud potřebujete
grid on
set(gcf, 'Position', [100,100,500,400])

%%
% Definice dat pro tabulku
models = {'Pretrained', 'LJSpeech100', 'LJSpeech50', 'LJSpeech25', 'LJSpeech12', 'LJSpeech6', 'Different Samples'}';
medians = [medianPretrained, medianFull, medianHalf, medianQuarter, medianEighth, medianSixteenth, medianDifferent]';
q1s = [q1Pretrained, q1Full, q1Half, q1Quarter, q1Eighth, q1Sixteenth, q1Different]';
q3s = [q3Pretrained, q3Full, q3Half, q3Quarter, q3Eighth, q3Sixteenth, q3Different]';
p5s = [percentile5Pretrained, percentile5Full, percentile5Half, percentile5Quarter, percentile5Eighth, percentile5Sixteenth, percentile5Different]';
p95s = [percentile95Pretrained, percentile95Full, percentile95Half, percentile95Quarter, percentile95Eighth, percentile95Sixteenth, percentile95Different]';

% Vytvoření tabulky
statsTable = table(models, medians, q1s, q3s, p5s, p95s, ...
                   'VariableNames', {'Model', 'Median', 'Q1', 'Q3', 'P5', 'P95'});

% Zobrazení tabulky
disp(statsTable)




