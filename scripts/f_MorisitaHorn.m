function [Sfull] = f_MorisitaHorn(X, SamplesInRows)
% f_MorisitaHorn calculates the Morisita-Horn index of similarity between samples.
%
%   [Sfull] = f_MorisitaHorn(X, SamplesInRows)
%
%           2 * sum_k (x_ik * x_jk)
%   S_ij = ---------------------------
%          sum_k (x_ik^2) + sum_k (x_jk^2)
%
% Where:
%   - x_ik is the relative abundance of species k in sample i
%   - The sums run over all species k

%   Arguments:
%     X              : Matrix of species abundances (samples x species by default)
%     SamplesInRows  : Logical flag. If true (default), each row is a sample. 
%                      If false, samples are in columns.
%
%   Returns:
%     Sfull          : Matrix of pairwise Morisita-Horn similarity indices (range 0–1)
%
%   The Morisita-Horn index is a quantitative measure of similarity between
%   two communities, accounting for both species identity and their abundances.

    if nargin < 2
        SamplesInRows = true; % Default orientation
    end

    if ~SamplesInRows
        X = X'; % Transpose so that samples are in rows
    end

    % Normalize abundances to relative abundances per sample
    rowSums = sum(X, 2);           % Sum of abundances for each sample (row)
    nonzeroRows = rowSums > 0;     % Logical index for nonzero-sum samples

    Xnorm = zeros(size(X));
    Xnorm(nonzeroRows, :) = X(nonzeroRows, :) ./ rowSums(nonzeroRows); % Only normalize nonzero rows

    % Compute pairwise dot products (numerators)
    pairwiseProducts = Xnorm * Xnorm'; % Dot product of all row pairs

    % Compute row-wise sum of squares (dominance terms)
    rowSumSquares = sum(Xnorm.^2, 2); % Column vector

    % Compute the denominator matrix (sum of dominance terms for each pair)
    denominatorMatrix = rowSumSquares + rowSumSquares'; % Pairwise sum

    % Compute the Morisita-Horn similarity matrix
    Sfull = 2 * pairwiseProducts ./ denominatorMatrix;

    % Avoid NaN for pairs involving zero-sum samples
    Sfull(denominatorMatrix == 0) = NaN; % Or set to zero if you prefer: Sfull(denominatorMatrix == 0) = 0;

    % Set diagonal to 1 (identical samples)
    Sfull(1:size(X, 1) + 1:end) = 1;

end
