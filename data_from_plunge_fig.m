function [x, z] = data_from_plunge_fig(fig)
% to pull data from a figure
dataObjs = findobj(fig,'-property','YData');
for ii = 1:length(dataObjs)
    x{ii} = dataObjs(ii).XData;
    z{ii} = dataObjs(ii).YData;
end
shift = 6;
for ii = 1:6
    x1{ii} = x{shift};
    z1{ii} = z{shift};
    shift = shift-1;
end
x = x1;
z = z1;
for ii = 1:6
x{ii} = x{ii}';
z{ii} = z{ii}';
end