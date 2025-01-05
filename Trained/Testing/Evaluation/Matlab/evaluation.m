close all
clear

%% Evaluation
% tacotron testing script output data processing

% 10 % LJ speech (.wavs) - ORIG vs. SYNTH

projectpath = 'C:\Users\username\Documents\E2E-thesis';     %full path to E2E-thesis project folder
data_subset = 'JLSpeech100';                                %change to your model name
addpath([projectpath, '\Trained\Testing\Evaluation\Matlab'])

%%
Metadata = [projectpath, '\Dataset\modified_datasets\LJSpeech_10\metadata.csv'];
Metadata = readtable(Metadata);
names = Metadata{:, 1};

clear Metadata

SynthDIR = [projectpath, '\Trained\Testing\Evaluation\Matlab\', data_subset, '\oputputs\outs_wav'];
OrigDIR =  [projectpath, '\Dataset\modified_datasets\LJSpeech_10\wavs'];

OutputDIR = [projectpath, '\Trained\Testing\Evaluation\Matlab\', data_subset, '\eval_outputs'];
OutputTime = fullfile(OutputDIR, 'time');
OutputSpec = fullfile(OutputDIR, 'spec');
OutputDTW = fullfile(OutputDIR, 'dtw');

% Vytvoření složek, pokud neexistují
if ~exist(OutputTime, 'dir')
    mkdir(OutputTime);
end
if ~exist(OutputSpec, 'dir')
    mkdir(OutputSpec);
end
if ~exist(OutputDTW, 'dir')
    mkdir(OutputDTW);
end

fig = 1;


for i = 1:length(names)
    file_orig = fullfile(OrigDIR, [names{i}, '.wav']);
    file_synth = fullfile(SynthDIR, [names{i}, '.wav']);

    [y_orig, Fs_orig] = audioread(file_orig);
    [y_synth, Fs_synth] = audioread(file_synth);


    t_orig = (0:length(y_orig)-1) / Fs_orig;
    t_synth = (0:length(y_synth)-1) / Fs_synth;

    figure (fig)
    % Časová doména - orig.
    subplot(211)
    plot(t_orig, y_orig)
    title(['Orig.', names{i}])
    xlabel('Time [s]')
    ylabel('Amplitude')
    ylim([-1, 1])
    grid on

    % Časová doména - synth
    subplot(212)
    plot(t_synth, y_synth)
    title(['Synth.', names{i}])
    xlabel('Time [s]')
    ylabel('Amplitude')
    ylim([-1, 1])
    grid on

    sgtitle(['Časový průběh: ', names{i}]);

    common_caxis = [-140 -40];

    % Uložení obrázků
    output_file_time = fullfile(OutputTime, [names{i}, '_time.png']);
    saveas(gcf, output_file_time);

    fig = fig+1;

    % Mel-spektrogram - orig.
    figure(fig)
    %subplot(211)
    melSpectrogram(y_orig, Fs_orig, 'NumBands',80)
    title('Mel-Spec. Original')
    xlabel('Time [s]')
    ylabel('Frequency [Mel]')
    colorbar off
    colormap jet
    clim(common_caxis)

    % Mel-spektrogram - synth.
    figure(fig)
    %subplot(212)
    melSpectrogram(y_synth, Fs_synth, 'NumBands', 80)
    title('Mel-Spec. Syntesized')
    xlabel('Time [s]')
    ylabel('Frequency [Mel]')
    colorbar off
    colormap jet
    clim(common_caxis)
    fig = fig+1;
    %sgtitle(['Mel-Spektrogram: ', names{i}]);

    % Uložení obrázků
    output_file_spec = fullfile(OutputSpec, [names{i}, '_spec.png']);
    saveas(gcf, output_file_spec);
end

%%

fmin = 0;
fmax = 8000;
M = 80;
cp = 12;
preem = -0.97;
wlen = 1024;
wstep=256;

cumulative_distances = zeros(1, 10);

global_min_cepdist = inf;
global_max_cepdist = -inf;

global_min_cumuldist = inf;
global_max_cumuldist = -inf;

for i = 1:length(names)

    % Získání kepstra z originálních promluv
    file_orig = fullfile(OrigDIR, [names{i}, '.wav']);
    [y_orig, Fs_orig] = audioread(file_orig);
    t_orig = (0:length(y_orig)-1) / Fs_orig;
    sp1 = filter([1 preem],1,y_orig);
    cs1 = vmfcc(sp1,1,cp,M,wlen,Fs_orig,fmin,fmax,wstep);
    cepstr1 = cs1(:, 2:end);
    len1 = size(cepstr1,1);
    frames1 = 1:len1;

    % Získání kepstra ze syntetických promluv
    file_synth = fullfile(SynthDIR, [names{i}, '.wav']);
    [y_synth, Fs_synth] = audioread(file_synth);
    t_synth = (0:length(y_synth)-1) / Fs_synth;
    sp2 = filter([1 preem],1,y_synth);
    cs2 = vmfcc(sp2,1,cp,M,wlen,Fs_orig,fmin,fmax,wstep);
    cepstr2 = cs2(:, 2:end);
    len2 = size(cepstr2,1);
    frames2 = 1:len2;

    %Kepstrální vzdálenost
    cepdist1 = zeros(len1,len2) ;

    for ii = 1:len1,
        for jj=1:len2,
            cepdist1(ii,jj) = cd1 ( cepstr1(ii,:), cepstr2(jj,:) ) ;
        end
    end

    % Aktualizace globálního rozsahu pro kepstrální vzdálenosti
    global_min_cepdist = min(global_min_cepdist, min(cepdist1(:)));
    global_max_cepdist = max(global_max_cepdist, max(cepdist1(:)));

    figure(fig)
    subplot(121)
    h = pcolor(frames2, frames1, cepdist1);
    axis ij;
    colormap jet; shading flat
    xlabel('cepstr2')
    ylabel('cepstr1')
    title(['Cepstral distance - ' names{i}])
    hold on


    caxis([15, 456]);
        
    % Kumulativní vzdálenost
    cumuldist1 = zeros(size(cepdist1)) ;
    cumuldist1(1,:) = cumsum(cepdist1(1,:)) ;
    cumuldist1(:,1) = cumsum(cepdist1(:,1)) ;

    len1 = size(cepdist1,1);
    len2 = size(cepdist1,2);

    for ii = 2:len1
        for jj = 2:len2
            cumuldist1(ii,jj) = min([cumuldist1(ii-1,jj) + cepdist1(ii,jj) , cumuldist1(ii,jj-1) + cepdist1(ii,jj),  cumuldist1(ii-1,jj-1) + cepdist1(ii,jj) ]);
        end
    end
    cumuldist1 = cumuldist1./len1./len2 ;

    cumulative_distances(i) = cumuldist1(len1, len2);
    

    % Aktualizace globálního rozsahu pro kumulativní vzdálenosti
    global_min_cumuldist = min(global_min_cumuldist, min(cumuldist1(:)));
    global_max_cumuldist = max(global_max_cumuldist, max(cumuldist1(:)));

    subplot (122)
    frames1 = 1:len1 ;
    frames2 = 1:len2 ;
    h = pcolor(frames2, frames1, cumuldist1);
    axis ij
    colormap jet
    shading flat
    xlabel('cepstr2')
    ylabel('cepstr1')
    title(['Cumulative distance = ' num2str(cumuldist1(len1, len2))])

     caxis([0, 0.3]);

    % Uložení obrázků
    output_file_dtw = fullfile(OutputDTW, [names{i}, '_DTW_repre.png']);
    saveas(gcf, output_file_dtw);

    fig =  fig+1;
end

output_mat_file = fullfile(OutputDTW, 'cumulative_distances_', data_subset, '.mat');
save(output_mat_file, 'cumulative_distances');




