function [mdl, s] = plot_fit_CI(x, y, sz, c, alpha, LineColor, dataMarker, y_power)
arguments
    x 
    y
    sz
    c
    alpha = 1;
    LineColor = 'k';
    dataMarker = 'o';
    y_power = 1; % power to transform the response variable. e.g. 1/2 or 1/4
end
    % plot_fit_CI - Plots a scatter plot of x and y, runs linear regression,
    % and plots the linear regression with a confidence interval.
    %
    % Parameters:
    %   x  - x data
    %   y  - y data
    %   sz - Marker size for scatter plot
    %   c  - Color for scatter plot
    %
    % Returns:
    %   mdl - Linear model object returned by fitlm
    %
    % Example:
    %   x = 1:10;
    %   y = x + randn(1,10);
    %   mdl = plot_fit_CI(x, y, 50, 'b');

    %Remove nan points
    nanData = isnan(x) | isnan(y);
    x = x(~nanData);
    y = y(~nanData);
    if ~isscalar(sz)
        sz = sz(~nanData);
    end
    % Scatter plot
    s = scatter(x, y, sz, c, 'filled', dataMarker);
    s.MarkerFaceAlpha = alpha;
    hold on;

    % Fit linear regression model using fitlm
    mdl = fitlm(x, y.^y_power);

    % Get confidence intervals
    x_sorted = sort(x(:)');
    [y_fit, y_ci] = predict(mdl, x_sorted');
    y_fit = y_fit.^(1/y_power);
    y_ci = y_ci.^(1/y_power);
    % Plot regression line
    if mdl.Coefficients.pValue(2) <= 0.05
        plot(x_sorted, y_fit, '-', 'LineWidth', 1.5, 'Color', LineColor);
    else 
        plot(x_sorted, y_fit, '--', 'LineWidth', 1, 'Color', LineColor);
    end
    % Plot confidence interval
    f = fill([x_sorted'; flipud(x_sorted')], [y_ci(:, 1); flipud(y_ci(:, 2))], c, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    f.Annotation.LegendInformation.IconDisplayStyle ="off";

    % Labels and settings
    xlabel('x');
    ylabel('y');
    grid on;
    hold off;
end
