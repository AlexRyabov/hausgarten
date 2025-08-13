function [Slope, Intercept] = wols_line(x,y, w)
arguments
    x;
    y;
    w = ones(size(x));
end
% Weighted orthogonal least squares fit of line y = Slope*x + Intercept to a set of 2D points with coordiantes given by x and y 
indVals = (isfinite(x) & isfinite(y) );
[a1, b1, c1] = wols(x(indVals), y(indVals), w(indVals));
Slope = -a1/b1; 
Intercept = -c1/b1;