
clear all
close all

load('recession_vs_angle_data_final.mat')

r2 = @(y, model) 1 - sum((y-model(x)).^2)/sum((y-mean(y)).^2);

%% testsing testin gtetsting testing tesing

%% PLOT SETTINGS
text_size = 18;
linestyle.colors = linspecer(6);
linestyle.marker_size = 12;
linestyle.width = 1.95;

%% MANIPULATE EMPIRICAL DATA
% all of the data
angles.all   = recession_vs_angle_data.angle(:);
max_nose.all = recession_vs_angle_data.max_nose(:);
max_edge.all = recession_vs_angle_data.max_edge(:);
serial.all   = recession_vs_angle_data.serial(:);

% with outliers removed
angles.no_outliers   = recession_vs_angle_data_no_outliers.angle(:);
max_nose.no_outliers = recession_vs_angle_data_no_outliers.max_nose(:);
max_edge.no_outliers = recession_vs_angle_data_no_outliers.max_edge(:);
serial.no_outliers   = recession_vs_angle_data_no_outliers.serial(:);

%% AVERAGED DATA
angles.unique = unique(abs(angles.all));
avg_nose.all = nan(length(angles.unique),1);
avg_edge.all = nan(length(angles.unique),1);
std_nose.all = nan(length(angles.unique),1);
std_edge.all = nan(length(angles.unique),1);

% with outliers removed
angles.unique_no_outliers = unique(abs(angles.no_outliers));
avg_nose.no_outliers = nan(length(angles.unique_no_outliers),1);
avg_edge.no_outliers = nan(length(angles.unique_no_outliers),1);
std_nose.no_outliers = nan(length(angles.unique_no_outliers),1);
std_edge.no_outliers = nan(length(angles.unique_no_outliers),1);

for ii = 1:length(angles.unique)
    avg_nose.all(ii) = nanmean(max_nose.all(abs(angles.all) == angles.unique(ii)));
    avg_edge.all(ii) = nanmean(max_edge.all(abs(angles.all) == angles.unique(ii)));
    
    std_nose.all(ii) = nanstd(max_nose.all(abs(angles.all) == angles.unique(ii)));    
    std_edge.all(ii) = nanstd(max_edge.all(abs(angles.all) == angles.unique(ii)));
end

for ii = 1:length(angles.unique_no_outliers)
    avg_nose.no_outliers(ii) = ...
        nanmean(max_nose.no_outliers(abs(angles.no_outliers) == angles.unique_no_outliers(ii)));
    avg_edge.no_outliers(ii) = ...
        nanmean(max_edge.no_outliers(abs(angles.no_outliers) == angles.unique_no_outliers(ii)));
    
    std_nose.no_outliers(ii) = ...
        nanstd(max_nose.no_outliers(abs(angles.no_outliers) == angles.unique_no_outliers(ii)));    
    std_edge.no_outliers(ii) = ...
        nanstd(max_edge.no_outliers(abs(angles.no_outliers) == angles.unique_no_outliers(ii)));
end

% only negative
angles.unique_neg = unique(abs(angles.unique_no_outliers(angles.unique_no_outliers<0)));
avg_nose.neg = nan(length(angles.unique_neg),1);
avg_edge.neg = nan(length(angles.unique_neg),1);
std_nose.neg = nan(length(angles.unique_neg),1);
std_edge.neg = nan(length(angles.unique_neg),1);

for ii = 1:length(angles.unique_neg)
    avg_nose.neg(ii) = ...
        nanmean(max_nose.no_outliers(abs(angles.unique_no_outliers(angles.unique_no_outliers<0)) == angles.unique_neg(ii)));
    avg_edge.neg(ii) = ...
        nanmean(max_edge.no_outliers(abs(angles.unique_no_outliers(angles.unique_no_outliers<0)) == angles.unique_neg(ii)));
    
    std_nose.neg(ii) = ...
        nanstd(max_nose.no_outliers(abs(angles.unique_no_outliers(angles.unique_no_outliers<0)) == angles.unique_neg(ii)));    
    std_edge.neg(ii) = ...
        nanstd(max_edge.no_outliers(abs(angles.unique_no_outliers(angles.unique_no_outliers<0)) == angles.unique_neg(ii)));
end

% 1= KY, 0 = ET
% brand_array = nan(length(serial),1);
% for ii = 1:length(serial)
%     str = char(serial(ii));
%     if regexp(str, 'K.*Y')
%         brand = 'KY';
%         brand_array(ii) = 1;
%     elseif regexp(str, 'ET|E.*h')
%         brand = 'ET';
%         brand_array(ii) = 0;
%     end
% end

%% DEVELOP MODEL

d = 3.56*1e-1;  % lattice distance (nm)
E = 6.22*10^-10; % C-C bond strength [ nJ ]
% formula for bonds broken per unit area at a given miller index
% this can also be thought of as bond density
% hkl = miller index as 1x3 vector
% d   = lattice distance
% units: bonds/area^2
n_hkl = @(hkl) 4*max(hkl)/d^2/norm(hkl);

% formula to translate miller indices into theta value wrt surface
% units = degrees
theta = @(hkl_ref, hkl) acosd(hkl_ref*hkl'/norm(hkl_ref)/norm(hkl));

% min-max normalization of a data set
minmax_scaler = @(x) (x - min(x))./(max(x) - min(x));
custom_scaler = @(x, b, a) (x - min(x)).*(b-a)./(max(x) - min(x));

hkl = [0 0 1; 1 1 0  ; 1 1 0.5; 1 1 1  ; 1 1 1.2; 1 1 1.5;
       1 1 2; 1 1 2.5; 1 1 3  ; 1 1 3.5; 1 1 4  ; 1 1 6  ;
       1 1 8; 3 3 2  ; 4 4 2  ; 2 2 1  ; 3 3 1  ; 4 4 1 ];

n_broken = nan(1, size(hkl, 1));
cleavage_energy = nan(1, size(hkl, 1));
theta_calc = nan(1, size(hkl, 1));

for ii = 1:size(hkl, 1)
    n_broken(ii) = n_hkl(hkl(ii,:));
    cleavage_energy(ii) = n_broken(ii)*E;
    theta_calc(ii) = theta(hkl(1,:), hkl(ii,:));
end   

bond_distance = 1./n_broken;
norm_bond_distance = minmax_scaler(bond_distance);

%% quadratic fit to bond distance up to 55 degrees
[xData, yData] = prepareCurveData( theta_calc(theta_calc<=55),...
                                   bond_distance(theta_calc<=55));

% Set up fittype and options.
ft = fittype( 'poly3' );

% Fit model to data.
[fitresult_theory, gof_theory] = fit( xData, yData, ft );


%% CREATE FIGURES AND AXES
fig_names = {'All angle data',...
             'With outliers removed',...
             'Average nose and leading edge'};
         
figs.all_data = figure();
clf
figs.no_outliers = figure();
clf
figs.avg_nose_and_lead_edge = figure();
clf
% figs.avg_nose_and_lead_edge_neg = figure();
% clf

fig_fn = fieldnames(figs); 
for ii = 1:numel(fig_fn)
    % loop structure by field name, set Units and NumberTitle properties
    figs.(fig_fn{ii}).Units = 'normalized';  
    figs.(fig_fn{ii}).NumberTitle = 'off';
    figs.(fig_fn{ii}).Name = fig_names{ii};
    figs.(fig_fn{ii}).Color = 'w';    
end

angle_axes.all_data = axes(figs.all_data);
angle_axes.no_outliers = axes(figs.no_outliers);
angle_axes.avg_nose_and_lead_edge = axes(figs.avg_nose_and_lead_edge);
% angle_axes.avg_nose_and_lead_edge_neg = axes(figs.avg_nose_and_lead_edge_neg);

angle_axes_fn = fieldnames(angle_axes); 
for ii = 1:numel(angle_axes_fn)
    angle_axes.(angle_axes_fn{ii}).Units = 'normalized';  
    angle_axes.(angle_axes_fn{ii}).FontSize = text_size;   
    angle_axes.(angle_axes_fn{ii}).XTick = [0 5 10 15 20 25];
    angle_axes.(angle_axes_fn{ii}).XLabel.String = 'Tool Rotation (deg)';    
    angle_axes.(angle_axes_fn{ii}).YLabel.String = 'Maximum Recession (\mum)';    
    hold(angle_axes.(angle_axes_fn{ii}), 'on');
end
%% DETAILED DATA

%% FIRST, SHOW ALL THE DATA
p.a = plot(angle_axes.all_data, angles.all(angles.all>=0), max_nose.all(angles.all>=0));
p.a.Marker = 's';
p.a.Color = linestyle.colors(1,:);
hold on
p.b = plot(angle_axes.all_data, abs(angles.all(angles.all<0)), max_nose.all(angles.all<0));
p.b.Marker = 'o';
p.b.Color= linestyle.colors(2,:);
p.c = plot(angle_axes.all_data, abs(angles.all(angles.all>=0)), max_edge.all(angles.all>=0));
p.c.Marker = 'x';
p.c.Color= linestyle.colors(3,:);
p.d = plot(angle_axes.all_data, abs(angles.all(angles.all<0)), max_edge.all(angles.all<0));
p.d.Marker = '+';
p.d.Color= linestyle.colors(4,:);

legend(angle_axes.all_data,...
    {'(+) Nose', '(-) Nose', '(+) Edge', '(-) Edge'},...
    'Location', 'northwest');

%% THEN AGAIN WITHOUT THE OUTLIERS
p.e = plot(angle_axes.no_outliers, angles.no_outliers(angles.no_outliers>=0), max_nose.no_outliers(angles.no_outliers>=0));
p.e.Marker = 's';
p.e.Color = linestyle.colors(1,:);
hold on
p.f = plot(angle_axes.no_outliers, abs(angles.no_outliers(angles.no_outliers<0)), max_nose.no_outliers(angles.no_outliers<0));
p.f.Marker = 'o';
p.f.Color= linestyle.colors(2,:);
p.g = plot(angle_axes.no_outliers, abs(angles.no_outliers(angles.no_outliers>=0)), max_edge.no_outliers(angles.no_outliers>=0));
p.g.Marker = 'x';
p.g.Color= linestyle.colors(3,:);
p.h = plot(angle_axes.no_outliers, abs(angles.no_outliers(angles.no_outliers<0)), max_edge.no_outliers(angles.no_outliers<0));
p.h.Marker = '+';
p.h.Color= linestyle.colors(4,:);

leg1 = legend(angle_axes.no_outliers);
leg1.String =  {'(+) Nose', '(-) Nose', '(+) Edge', '(-) Edge'};
leg1.Location = 'northwest';


%% AVERAGE THE DATA WITHOUT OUTLIERS, SHOW WITH ERRORBARS
% set(0, 'currentfigure', figs.avg_nose_and_lead_edge); 
% 
% yyaxis left
p.i = errorbar(angle_axes.avg_nose_and_lead_edge,...
    angles.unique_no_outliers, avg_nose.no_outliers, std_nose.no_outliers);
p.i.Marker = 's';
p.i.Color  =  linestyle.colors(2,:);
p.i.MarkerEdgeColor = linestyle.colors(2,:);
p.i.MarkerFaceColor = 'none';

p.i.Bar.LineStyle = 'dotted';

p.j = errorbar(angle_axes.avg_nose_and_lead_edge,...
    angles.unique_no_outliers, avg_edge.no_outliers, std_edge.no_outliers);
p.j.Marker = 's';
p.j.Color  =  linestyle.colors(1,:);
p.j.MarkerEdgeColor = linestyle.colors(1,:);
p.j.MarkerFaceColor = 'none';

nose_errorbar.Bar.LineStyle = 'dotted';
ylabel('Average Recession (\mum)');
ylim(angle_axes.avg_nose_and_lead_edge,[0, 0.51])

plot_fn = fieldnames(p); 
for ii = 1:numel(plot_fn)
    p.(plot_fn{ii}).LineStyle = 'none';    
    p.(plot_fn{ii}).MarkerSize = linestyle.marker_size;
    p.(plot_fn{ii}).LineWidth = linestyle.width;       
end

[lgd, icons, plots, txt] = legend({'Nose', 'Leading Edge'},...
        'Location', 'northwest');
clear icons plots txt
%% WHAT ABOUT SAME AS ABOVE BUT ONLY NEGATIVE ANGLES
% set(0, 'currentfigure', figs.avg_nose_and_lead_edge_neg); 
% set(figs.avg_nose_and_lead_edge_neg,...
%     'defaultAxesColorOrder',[left_color; right_color]);
% % 
% yyaxis left
% nose_errorbar = errorbar(angle_axes.avg_nose_and_lead_edge_neg,...
%     angles.unique_neg, avg_nose.neg, std_nose.neg,...
%     'MarkerSize', linestyle.marker_size,...
%     'Marker', 's',...
%     'LineStyle', 'None',...
%     'LineWidth', linestyle.width,...
%     'Color', right_color,...
%     'MarkerEdgeColor', right_color,...
%     'MarkerFaceColor', 'none');
% 
% nose_errorbar.Bar.LineStyle = 'dotted';
% ylabel(angle_axes.avg_nose_and_lead_edge_neg,'Avg. Nose Recession Neg(\mum)');
% ylim(angle_axes.avg_nose_and_lead_edge_neg,[0, 0.5])
% 
% yyaxis right
% nose_errorbar = errorbar(angle_axes.avg_nose_and_lead_edge_neg,...
%     angles.unique_neg, avg_edge.neg, std_edge.neg,...
%     'MarkerSize', linestyle.marker_size,...
%     'Marker', 'o',...
%     'LineStyle', 'None',...
%     'LineWidth', linestyle.width,...
%     'Color', right_color,...
%     'MarkerEdgeColor', right_color,...
%     'MarkerFaceColor', 'none');
% 
% nose_errorbar.Bar.LineStyle = 'dotted';
% ylabel(angle_axes.avg_nose_and_lead_edge_neg,'Avg. Edge Recession Neg (\mum)');
% ylim(angle_axes.avg_nose_and_lead_edge_neg,[0, 0.5])

%% QUADRATIC FITS TO AVERAGED DATA

% yyaxis right
% edge_errorbar = errorbar(unique_angles, avg_edge, std_edge, 'MarkerSize', marker_size, 'Marker', 'o', 'LineStyle', 'None');
% edge_errorbar.LineWidth = 1.25;            
% edge_errorbar.Color = [188,189,220]./255;
% edge_errorbar.MarkerEdgeColor = right_color;
% edge_errorbar.MarkerFaceColor = 'none';
% edge_errorbar.Bar.LineStyle = 'dotted';
% ylabel('Average Edge Recession (\mum)');
% title(leg, 'Cut Dist. (m)');  
%% BOND DENSITY
bond_density_fig = figure('Name', 'Bond Density');
set(0, 'currentfigure', bond_density_fig); 
set(bond_density_fig,...
    'defaultAxesColorOrder',[[0 0 0]; [0 0 0]]);
% bond_density_ax = axes(bond_density_fig);
ylim_left_1 = [15 32]; %n/nm^2

yyaxis left
p1.a = plot(theta_calc, n_broken,...
    'MarkerSize', linestyle.marker_size*.2,...
    'Marker', 's',...
    'LineStyle', 'None',...
    'LineWidth', linestyle.width,...
    'Color', linestyle.colors(2,:),...
    'MarkerEdgeColor', linestyle.colors(2,:),...
    'MarkerFaceColor', 'none');
ylabel('Bond density (n\cdotnm^{-2})', 'FontSize', text_size);
ylim(ylim_left_1)
yyaxis right
p1.b = plot(theta_calc, cleavage_energy,...
    'MarkerSize', linestyle.marker_size,...
    'Marker', 's',...
    'LineStyle', 'None',...
    'LineWidth', linestyle.width,...
    'Color', linestyle.colors(2,:),...
    'MarkerEdgeColor', linestyle.colors(2,:),...
    'MarkerFaceColor', 'none');
ylabel('Cleavage energy (J\cdotnm^{-2} )', 'FontSize', text_size);
ylim(ylim_left_1.*E)
xlabel('Tool Rotation (deg)', 'FontSize', text_size);
xticks([0 30 60 90])

%% BOND DISTANCE
bond_distance_fig = figure('Name', 'Bond Density');
set(0, 'currentfigure', bond_distance_fig); 
set(bond_distance_fig,...
    'defaultAxesColorOrder',[[0 0 0]; [0 0 0]]);

ylim_left_2 = [min(bond_distance) max(bond_distance)]; %n/nm^2
yyaxis left
[theta_sorted, theta_sorted_ind] = sort(theta_calc);
bond_dist_sorted = bond_distance(theta_sorted_ind);
%     plot(theta_calc, bond_distance,...
p1.c = plot(theta_sorted, bond_dist_sorted,...
    'LineWidth', linestyle.width,...
    'Color', linestyle.colors(2,:),...
    'MarkerEdgeColor', linestyle.colors(2,:),...
    'MarkerFaceColor', 'none');
xlabel('\theta (deg)', 'FontSize', text_size);
% ylabel('Avg Distance Between Bonds $$\left( \frac{\textrm{nm}^2}{\textrm{n}} \right)$$', 'Interpreter', 'Latex', 'FontSize', text_size);
ylabel({'Average Distance', 'Between Bonds ( nm^2n^{-1} )'},'FontSize', text_size);

ylim(ylim_left_2)
yyaxis right
% ylim_right_2 = ylim_left_2.*[0  1/max(bond_distance)]; %n/nm^2
p1.d = plot(theta_calc, norm_bond_distance,...
    'MarkerSize', linestyle.marker_size*.4,...
    'Marker', 'o',...
    'LineStyle', 'None',...
    'LineWidth', linestyle.width,...
    'Color', linestyle.colors(2,:),...
    'MarkerEdgeColor', linestyle.colors(2,:),...
    'MarkerFaceColor', 'none');
ylabel({'Normalized Avg Distance', 'Between Bonds'},'FontSize', text_size);
% ylim(ylim_right_2)
xticks([0 30 60 90])

%% compare averaged data to normalized data
% data to look at:
% angles.unique_no_outliers, avg_edge.no_outliers
% angles.unique_no_outliers, avg_nose.no_outliers

% norm_avg_nose = custom_scaler(avg_nose, .1073, 0);
% norm_avg_edge = custom_scaler(avg_edge, .1073, 0);

%% fit to normalized theory
[xData1, yData1] = prepareCurveData( theta_calc(theta_calc<=55),...
                                   norm_bond_distance(theta_calc<=55));

% Fit model to data.
[fitresult_norm_theory, gof_norm_theory] = fit( xData1, yData1, ft );

avg_edge.normalized = ...
    custom_scaler(avg_edge.no_outliers, fitresult_norm_theory(22.5), 0);
avg_nose.normalized = ...
    custom_scaler(avg_nose.no_outliers, fitresult_norm_theory(22.5), 0);

%% NOSE WEAR - DETAILED DATA
% nose_detail_fig = figure('Name', 'Nose Wear Detail');
% % KY positive
% plot(angles(positive_angles & brand_array), max_nose(positive_angles & brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', 's', 'Color', pos_color, 'LineWidth', line_width);
% hold on
% % KY negative
% plot(abs(angles(negative_angles & brand_array)), max_nose(negative_angles & brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', '*', 'Color', pos_color, 'LineWidth', line_width);
% % ET positive
% plot(angles(positive_angles & ~brand_array), max_nose(positive_angles & ~brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', 'o', 'Color', neg_color, 'LineWidth', line_width);
% hold on
% % ET negative
% plot(abs(angles(negative_angles & ~brand_array)), max_nose(negative_angles & ~brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', '+', 'Color', neg_color, 'LineWidth', line_width);
% 
% legend({'Brand 1, (+) $\theta$', 'Brand 1, (-) $\theta$', 'Brand 2, (+) $\theta$', 'Brand 2, (-) $\theta$'},...
%        'Location', 'NorthWest', 'Interpreter', 'latex', 'FontSize', font_size-4)
% % axis([-.5 25 0 .65]);
% 
% xlabel('Angle (deg)', 'FontSize', font_size);
% ylabel('Recession (\mum)', 'FontSize', font_size);
% axis([-.5 25 0 1.8])
% % axis([-.5 25 0 .65])
% 
% %% EDGE WEAR - DETAILED DATA
% edge_detail_fig = figure('Name', 'Edge Wear Detail');
% % KY positive
% plot(angles(positive_angles & brand_array), max_edge(positive_angles & brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', 's', 'Color', pos_color, 'LineWidth', line_width);
% hold on
% % KY negative
% plot(abs(angles(negative_angles & brand_array)), max_edge(negative_angles & brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', '*', 'Color', pos_color, 'LineWidth', line_width);
% % ET positive
% plot(angles(positive_angles & ~brand_array), max_edge(positive_angles & ~brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', 'o', 'Color', neg_color, 'LineWidth', line_width);
% hold on
% % ET negative
% plot(abs(angles(negative_angles & ~brand_array)), max_edge(negative_angles & ~brand_array),...
%     'LineStyle', 'None', 'MarkerSize', marker_size, 'Marker', '+', 'Color', neg_color, 'LineWidth', line_width);
% 
% legend({'Brand 1, (+) $\theta$', 'Brand 1, (-) $\theta$', 'Brand 2, (+) $\theta$', 'Brand 2, (-) $\theta$'},...
%        'Location', 'NorthWest', 'Interpreter', 'latex', 'FontSize', font_size-4)
% 
% xlabel('Angle (deg)', 'FontSize', font_size);
% ylabel('Recession (\mum)', 'FontSize', font_size);
% 
% %% AVERAGED DATA
% unique_angles = unique(abs(angles));
% avg_nose = nan(length(unique_angles),1);
% avg_edge = nan(length(unique_angles),1);
% std_nose = nan(length(unique_angles),1);
% std_edge = nan(length(unique_angles),1);
% 
% for ii = 1:length(unique_angles)
%     avg_nose(ii) = nanmean(max_nose(abs(angles) == unique_angles(ii)));
%     avg_edge(ii) = nanmean(max_edge(abs(angles) == unique_angles(ii)));
%     
%     std_nose(ii) = nanstd(max_nose(abs(angles) == unique_angles(ii)));    
%     std_edge(ii) = nanstd(max_edge(abs(angles) == unique_angles(ii)));
% end
% 
% %% AVERAGED DATA
% avg_fig = figure('Name', 'Averaged Nose and Averaged Edge Wear');
% 

% 
% xlabel('Angle (deg)');
% 
% print_png(nose_detail_fig, [3.5, 2.5],  'nose_detail_wear_with_outlier');
% print_png(edge_detail_fig, [3.5, 2.5],  'edge_detail_wear_with_outlier');
% print_png(avg_fig, [3.5, 2.5],  'avg_nose_and_avg_edge_wear_with_outlier');
