function [indMostAbund, namesMostAbund] = f_GetMostAbundant( ...
    samples, AllNames)
%find total abundandance for each group, return names and indexes in the order od decreasing abundance
[dTotAbundance, sNames] = grpstats(samples, AllNames, {"sum", "gname"});
[~, indMostAbund] = sort(dTotAbundance, "descend");
namesMostAbund = sNames(indMostAbund);
end
