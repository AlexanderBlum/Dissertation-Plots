function resid_plot_from_plunges(x, z)
%% example residual plots
% this script creates the following figures:
% 1: example residual, unfiltered
% 2: example residual, filetered

% this script has the following dependencies:
% fit_unworn_plunge: (fits a circle to trimmed unworn plunge)
% uncut_chip: (creates the z array for the uncut chip)
% linspecer: (for plot colors)

% clear all

% parameters for all figures
text_size = 18;

%% example residual plots

%% parameters and load data
%  data in example_resid_data is from ET 2020220 -10 deg 0% o2 run
%  data in example_resid_data_2 is from KY 314561-22.5 deg 20% o2 run
filter_cutoff = 4; % micrometers

ax_lims = [-80  80  -0.1  .3];  
yTickSpacing = 0.3;
ind_to_plot = [1 2 4 6];
line_styles = {'-', '--',':','-.', '-', '--'};
line_colors = linspecer(6);

% load example_resid_data_2.mat x z

%% calculations
% fit to plunge 0
[fitresult, gof] = fit_unworn_plunge(x{1}, z{1});

% row 1 is unfiltered
% row 2 is filtered
resid = cell(2, length(x));
% find residuals
for ii = 1:length(x)
    resid{1,ii} = z{ii} - fitresult(x{ii});
    resid{2,ii} = fourier_filter_1d(x{ii}-x{ii}(1), resid{1, ii},...
        0, filter_cutoff, 'bandstop');
end

z_chip = uncut_chip(5, 2, x{1});

%% create figures
resid_ax_pos = [0.135  0.180+.145  0.7  0.785-.150];
chip_ax_pos = [.135 .21 .7 .16];
ymax = yTickSpacing*round(ax_lims(4)/yTickSpacing);
resid_ax_ytick = 0:yTickSpacing:ymax;

% resid_fig.unfilt = figure();
% clf
resid_fig.filt = figure();
clf

fig_fn = fieldnames(resid_fig); 
for ii = 1:numel(fig_fn)
    % loop structure by field name, set Units and NumberTitle properties
    resid_fig.(fig_fn{ii}).Units = 'normalized';  
    resid_fig.(fig_fn{ii}).NumberTitle = 'off';
    resid_fig.(fig_fn{ii}).Name = 'Plunge Residuals';
    resid_fig.(fig_fn{ii}).Color = 'w';    
end

% resid_ax.unfilt = axes(resid_fig.unfilt);
resid_ax.filt = axes(resid_fig.filt);
resid_ax_fn = fieldnames(resid_ax);
for ii = 1:numel(resid_ax_fn)
    resid_ax.(resid_ax_fn{ii}).Units = 'normalized';  
    resid_ax.(resid_ax_fn{ii}).FontSize = text_size; 
    resid_ax.(resid_ax_fn{ii}).Position = resid_ax_pos;    
    
    resid_ax.(resid_ax_fn{ii}).XLim = ax_lims(1:2);
    resid_ax.(resid_ax_fn{ii}).YLim = ax_lims(3:4);    
    
    resid_ax.(resid_ax_fn{ii}).XTick = [];    
    resid_ax.(resid_ax_fn{ii}).YTick = resid_ax_ytick;    
    resid_ax.(resid_ax_fn{ii}).XColor = 'w';
    
    
    resid_ax.(resid_ax_fn{ii}).YLabel.String = 'Edge Recession (\mum)';    
    
    hold(resid_ax.(resid_ax_fn{ii}), 'on');
end

% chip_ax.unfilt = axes(resid_fig.unfilt);
chip_ax.filt = axes(resid_fig.filt);
chip_ax_fn = fieldnames(resid_ax); 
for ii = 1:numel(chip_ax_fn)
    chip_ax.(chip_ax_fn{ii}).FontSize = text_size;
    chip_ax.(chip_ax_fn{ii}).Position = chip_ax_pos;
    chip_ax.(chip_ax_fn{ii}).Box = 'off';
    chip_ax.(chip_ax_fn{ii}).YAxisLocation = 'right';
    chip_ax.(chip_ax_fn{ii}).XLim = ax_lims(1:2);
    chip_ax.(chip_ax_fn{ii}).YLim = [0  2.1];

    chip_ax.(chip_ax_fn{ii}).XLabel.String = 'Location Along Plunge Edge (\mum)';
    chip_ax.(chip_ax_fn{ii}).YLabel.String = {'Uncut Chip'; 'Thickness (\mum)'};
    chip_ax.(chip_ax_fn{ii}).XTick = [-80 -40 0 40 80];
    hold(chip_ax.(chip_ax_fn{ii}), 'on')    
end

for jj = 1:numel(resid_ax_fn)
    for ii = ind_to_plot
        plot(resid_ax.(resid_ax_fn{jj}), x{ii}, resid{jj, ii},...
            'Color', line_colors(ind_to_plot == ii,:),...
            'LineWidth', 1.5,...
            'LineStyle', line_styles{find(ind_to_plot == ii)})  
    end
    area(chip_ax.(chip_ax_fn{jj}), x{1}, z_chip,... 
        'LineStyle', 'none',...
        'FaceColor', [120, 120, 120]./255)   
    leg = legend(resid_ax.(resid_ax_fn{jj}), {'0', '500', '1500', '2500'},...
        'Location', 'northwest');
    title(leg, 'Cut Dist. (m)');    
end
%% final alignment plots
