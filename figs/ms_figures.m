%%
clear, clc, close all;

figsFolder = fileparts(matlab.desktop.editor.getActiveFilename);
load(fullfile(figsFolder, 'data_for_figs.mat'));

lwd = 3;   % line width
fpt = 32;  % font size
dpi = 300; % resolution

%% FIGURE 1
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2, 1, 1);
plot(EcgMri.bad , 'Color', 'r', 'LineWidth', lwd);
title('Bad ECG');
set(gca,'FontSize', fpt);
xticks(0:1e4:5e4);
ylim([0 12]);
yticks(2:2:12);

subplot(2, 1, 2);
plot(EcgMri.good, 'Color', 'g', 'LineWidth', lwd);
title('Good ECG');
set(gca,'FontSize', fpt);
xticks(0:1e4:5e4);
ylim([0 12]);
yticks(2:2:12);

set(gca,'LooseInset', get(gca,'TightInset'));

fn = 'fig01.tiff';
exportgraphics(gcf, fullfile(figsFolder, fn), 'Resolution', dpi);
close all; 

%% FIGURE 2
getEcgThresh(Thresh.ecg, Thresh.mpSys);

set(gcf, 'Position', get(0, 'Screensize'));
set(gca,'LooseInset', get(gca,'TightInset'));

fn = 'fig02.tiff';
exportgraphics(gcf, fullfile(figsFolder, fn), 'Resolution', dpi);
close all;

%% FIGURE 3
plotTrial(Trial.data, Trial.ecg, Trial.mpSys);

set(gcf, 'Position', get(0, 'Screensize'));
set(gca,'LooseInset', get(gca,'TightInset'));

fn = 'fig03.tiff';
exportgraphics(gcf, fullfile(figsFolder, fn), 'Resolution', dpi);
close all;
