%%
clear, clc, close all;

figsFolder = fileparts(matlab.desktop.editor.getActiveFilename);
lwd = 3;  % line width
fpt = 32; % font size

%% FIGURE 1
load(fullfile(figsFolder, 'jors_fig01.mat'));

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

%% FIGURE 2

