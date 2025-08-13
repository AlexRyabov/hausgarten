function gplotmy(x, y, g, gList, clrs, ylimits,  varargin)
    % groupLinePlot plots a line for each group specified by g.
    % 
    % Inputs:
    %   x - A vector of x values
    %   y - A vector of y values
    %   g - A vector specifying the group for each x, y pair

    % Ensure the inputs are column vectors
    x = x(:);
    y = y(:);
    g = g(:);

    % Get unique groups
   % gList = unique(g);

    % Plot each group
    for i = 1:length(gList)
        groupIndex = strcmp(g, gList(i));
        semilogy(x(groupIndex), y(groupIndex), '-o', 'Color', clrs(i, :), 'DisplayName', gList{i}, varargin{:});
        ylim(ylimits);
        hold on; % Hold on to plot all groups on the same figure
    end

    % Add legend and labels
    hold off;
end
