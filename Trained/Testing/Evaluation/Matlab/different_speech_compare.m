close all
clear

projectpath = 'C:\Users\username\Documents\E2E-thesis';     %full path to E2E-thesis project folder
addpath([projectpath, '\Trained\Testing\Evaluation\Matlab'])

%%
Metadata = [projectpath, '\Dataset\modified_datasets\LJSpeech_10\metadata.csv'];
Metadata = readtable(Metadata);
names = Metadata{:, 1};

clear Metadata

OrigDIR =  [projectpath, '\Dataset\modified_datasets\LJSpeech_10\wavs'];
OutputDIR = [projectpath, '\Trained\Testing\Evaluation\Matlab\different_speech_compare'];
OutputDTW = fullfile(OutputDIR, 'dtw');

% Vytvoření složek, pokud neexistují

if ~exist(OutputDTW, 'dir')
    mkdir(OutputDTW);
end

% Parametry DTW
fmin = 0;
fmax = 8000;
M = 80;
cp = 12;
preem = -0.97;
wlen = 1024;
wstep = 256;
fig = 1;

% Počet náhodně vybraných dvojic
num_comparisons = 1273;
num_promluv = length(names);

% Inicializace proměnných
cumulative_distances = [];

% Generování náhodných indexů dvojic
rng(42); % Pro reprodukovatelnost


global_min_cepdist = inf;
global_max_cepdist = -inf;

global_min_cumuldist = inf;
global_max_cumuldist = -inf;

for idx = 1:10%num_comparisons
    i = randi([1, num_promluv],1);
    j = gen_unique(1, num_promluv, i);

    % Načtení prvního souboru
    file1 = fullfile(OrigDIR, [names{i}, '.wav']);
    [y1, Fs1] = audioread(file1);
    sp1 = filter([1 preem], 1, y1);
    cs1 = vmfcc(sp1, 1, cp, M, wlen, Fs1, fmin, fmax, wstep);
    cepstr1 = cs1(:, 2:end);
    len1 = size(cepstr1, 1);
    frames1 = 1:len1;

    % Načtení druhého souboru
    file2 = fullfile(OrigDIR, [names{j}, '.wav']);
    [y2, Fs2] = audioread(file2);
    sp2 = filter([1 preem], 1, y2);
    cs2 = vmfcc(sp2, 1, cp, M, wlen, Fs2, fmin, fmax, wstep);
    cepstr2 = cs2(:, 2:end);
    len2 = size(cepstr2, 1);
    frames2 = 1:len2;

    % Výpočet kepstrální vzdálenosti
    cepdist = zeros(len1, len2);
    for ii = 1:len1
        for jj = 1:len2
            cepdist(ii, jj) = cd1(cepstr1(ii, :), cepstr2(jj, :));
        end
    end

    % Aktualizace globálního rozsahu pro kepstrální vzdálenosti
    global_min_cepdist = min(global_min_cepdist, min(cepdist(:)));
    global_max_cepdist = max(global_max_cepdist, max(cepdist(:)));

    figure(fig)
    subplot(121)
    h = pcolor(frames2, frames1, cepdist);
    axis ij;
    colormap jet; shading flat
    xlabel('cepstr2')
    ylabel('cepstr1')
    title(['Cepstral distance - ' names{i} ' vs ' names{j}])
    hold on

    caxis([15, 456]);

    % Výpočet kumulativní vzdálenosti pomocí DTW
    cumuldist = zeros(size(cepdist));
    cumuldist(1, :) = cumsum(cepdist(1, :));
    cumuldist(:, 1) = cumsum(cepdist(:, 1));

    for ii = 2:len1
        for jj = 2:len2
            cumuldist(ii, jj) = min([
                cumuldist(ii-1, jj) + cepdist(ii, jj), ...
                cumuldist(ii, jj-1) + cepdist(ii, jj), ...
                cumuldist(ii-1, jj-1) + cepdist(ii, jj)
                ]);
        end
    end
    cumuldist = cumuldist ./ len1 ./ len2;

    % Uložení kumulativní vzdálenosti pro aktuální dvojici
    cumulative_distances = [cumulative_distances, cumuldist(len1, len2)];

    % Aktualizace globálního rozsahu pro kumulativní vzdálenosti
    global_min_cumuldist = min(global_min_cumuldist, min(cumuldist(:)));
    global_max_cumuldist = max(global_max_cumuldist, max(cumuldist(:)));

    subplot (122)
    frames1 = 1:len1 ;
    frames2 = 1:len2 ;
    h = pcolor(frames2, frames1, cumuldist);
    axis ij
    colormap jet
    shading flat
    xlabel('cepstr2')
    ylabel('cepstr1')
    title(['Cumulative distance = ' num2str(cumuldist(len1, len2))])


    % Uložení obrázků
    output_file_dtw = fullfile(OutputDTW, [names{i}, '_and_', names{j}, '_DTW_repre.png']);
    saveas(gcf, output_file_dtw);

end

% output_mat_file_different = fullfile(OutputDTW, 'cumulative_distances_different.mat');
% save(output_mat_file_different, 'cumulative_distances');


