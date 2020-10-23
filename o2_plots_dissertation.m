
% first plot all of the o2 vs wear data you can find
text_size = 18;
linestyle.colors = linspecer(6);
linestyle.marker_size = 12;
linestyle.width = 1.95;

o2       = [ 0        ,   5,   8,  11, 13.5, 15.5,  20];
max.nose = [(98+122)/2, 178, 268, 123,  212,  131, 139];
max.edge = [(58+78)/2 ,  56,  88,  50,   59,  117,  76];

fig = figure();
clf
ax = axes(fig);

fig.Units = 'normalized';  
fig.NumberTitle = 'off';
fig.Name = 'Plunge Residuals';
fig.Color = 'w';    

ax.Units = 'normalized';  
ax.FontSize = text_size;  

ax.XLabel.String = 'Oxygen Partial Pressure (% O_2)'; 
ax.YLabel.String = 'Edge Recession (nm)';    
ax.XLim = [-1 20];
ax.YLim = [0 300];
hold(ax, 'on');

p1 = plot(o2, max.nose);
p1.Marker = 's';
p1.LineStyle = 'none';
p1.LineStyle = 'none';    
p1.MarkerSize = linestyle.marker_size;
p1.LineWidth = linestyle.width;   
p1.Color= linestyle.colors(1,:);

p2 = plot(o2, max.edge);
p2.Marker = 'x';
p2.LineStyle = 'none';
p2.LineStyle = 'none';    
p2.MarkerSize = linestyle.marker_size;
p2.LineWidth = linestyle.width;   
p2.Color= linestyle.colors(2,:);

leg = legend(ax);
leg.String =  {'Nose', 'Edge'};
leg.Location = 'northwest';
% max.nose = [100 120 200 210 120 180 270 130];
% max.edge = [70 100 60 60 70 20 120 30];
% serial = [

% fig.t1 = figure();
% fig.t1.Name = 'Temp1';
% ax.t1 = axes(fig.t1);
% hold(ax.t1, 'on');
% fig.t2 = figure();
% ax.t2 = axes(fig.t2);
% fig.t2.Name = 'Temp2';
% hold(ax.t2, 'on');
% 
% fn = fieldnames(temp.one);
% for ii = 1:numel(fn)
% plot(ax.t1,...
%     (time.one.(fn{ii})-time.one.(fn{ii})(1))/1000/60, temp.one.(fn{ii}));
% plot(ax.t2,...
%     (time.two.(fn{ii})-time.two.(fn{ii})(1))/1000/60, temp.two.(fn{ii}));
% end
% 
% legend(ax.t1, fn);
% legend(ax.t2, fn);