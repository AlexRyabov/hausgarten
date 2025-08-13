%% Figures to HG review paper
% Fig. Station locations
% Fig. Eff sp number and chl-a in dependence of month and depth 
% Fig. Richness of main phyla in dependence of month, depth and location

%%Load Data
clearvars
close all

%Load samples
tSamples = readtable('..\GitHub\hausgarten\data\Bio.xlsx');
idxSamplCols = 8:width(tSamples);
SamplNames = tSamples.Properties.VariableNames(idxSamplCols);

%Load predictors
tStPredictors = readtable('..\GitHub\hausgarten\data\Env.xlsx');

%define the grouping variables
day_step = 21; %step of the day of year
tStPredictors.indDay = round(tStPredictors.doy/day_step)*day_step;
tStPredictors.indDepth = HG_isdeep(tStPredictors.Depth);
tStPredictors.indEast = HG_iseast(tStPredictors.Lon);

%find x most abundant families
%Top group name
speciesTaxonomy = {'Phylum', 'Class', 'Order', 'Family', 'Genus'};
keyFactor = 'indDay';

%% Make richness maps for west and east
iFgNr = 50;

iFgNr = HG_sd_CalcNPlot('plotRichnessMaps', struct('tSamples', tSamples, 'idxSamplCols', idxSamplCols, ...
    'tStPredictors', tStPredictors), iFgNr);
%% plot distribution of orders by months /depth/east west
topGroupName = 'Phylum'; topGroupPrefix = '^p_ ';
tSamples{:, topGroupName} = cellfun(@(x) regexprep(x, topGroupPrefix, ''), tSamples{:, topGroupName}, 'UniformOutput', false);
tSamples{:, topGroupName} = f_RemoveSpacesAndPrefix(tSamples{:, topGroupName});
[iFgNr, Results] = HG_sd_CalcNPlot('plotRichnessDistributionsError', struct('tSamples', tSamples, 'idxSamplCols', idxSamplCols, ...
    'tStPredictors', tStPredictors, 'topGroupName', topGroupName), iFgNr);


%% plot location of stations 
[iFgNr] = HG_CalcNPlot('PL_StationNames2', struct('tStPredictors', tStPredictors), iFgNr);



