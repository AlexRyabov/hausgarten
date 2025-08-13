function gplotmy_error(x, y, ylow, yhigh, g, gList, clrs, ylimits,  varargin)
% groupLinePlot plots a line for each group specified by g.
%
% Inputs:
%   x - A vector of x values
%   y - A vector of y values
%   g - A vector specifying the group for each x, y pair

% Ensure the inputs are column vectors
x = x(:);
y = y(:);
errBar = [yhigh-y, y-ylow]';
g = g(:);

% Get unique groups
% gList = unique(g);

% Plot each group
for i = 1:length(gList)
    groupIndex = strcmp(g, gList(i));
%    h = semilogy(x(groupIndex), y(groupIndex), '-o', 'Color', clrs(i, :), 'DisplayName', gList{i}, varargin{:});
    H  = shadedErrorBar(x(groupIndex), y(groupIndex), errBar(:, groupIndex),{ '-o', 'Color', clrs(i, :), 'DisplayName', gList{i}, varargin{:}}, 1);
    %        shadedErrorBar(x(groupIndex), y(groupIndex), errBar,'Color', clrs(i, :), 'DisplayName', gList{i}, varargin{:}, 0.5);
    H.edge(1).Annotation.LegendInformation.IconDisplayStyle = 'off'
    H.edge(2).Annotation.LegendInformation.IconDisplayStyle = 'off'
    H.patch.Annotation.LegendInformation.IconDisplayStyle = 'off'
    hold on; % Hold on to plot all groups on the same figure
end
set(gca, 'YScale','log')
ylim(ylimits);
% Add legend and labels
hold off;
end
