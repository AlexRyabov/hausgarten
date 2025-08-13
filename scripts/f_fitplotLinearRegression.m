function lm = f_fitplotLinearRegression(X, Y, Yerr,  ColorIn)
arguments
    X
    Y
    Yerr = []
    ColorIn = [1, 0, 0];
end

% Plot scatter points with specified color
[X, ind] = sort(X);
Y = Y(ind);
if isempty(Yerr)
    plot(X, Y, 'Color', ColorIn, 'LineStyle', 'none', Marker='o', MarkerFaceColor=ColorIn);
else
    Yerr = Yerr(ind);
    errorbar(X, Y, Yerr,  'Color', ColorIn, 'LineStyle', 'none', Marker='o', MarkerFaceColor=ColorIn);
end
hold on;

if length(unique(X)) < 2
    lm = [];
    return;
end

% Fit and plot a linear regression model
lm = fitlm(X, Y);
% Get coefficients and p-value of the slope
coef = lm.Coefficients.Estimate;
pValue = lm.Coefficients.pValue(2); % p-value for slope

% Generate x values for plotting the regression line
xRange = linspace(min(X), max(X), 100);
yFit = coef(1) + coef(2) * xRange;

% Choose line style based on p-value of the slope
if pValue < 0.01
    lineStyle = '-'; % Solid line
else
    lineStyle = '--'; % Dashed line
end

% Plot regression line with specified color and line style
plot(xRange, yFit, 'Color', ColorIn, 'LineStyle', lineStyle, 'LineWidth', 1.5);

% Set labels and title
hold off;
end
