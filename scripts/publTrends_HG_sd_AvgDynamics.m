%% Figures to HG review paper
%% plot dynamics of species groups
% Fig. Species abundance in dependence on month, spring-summer-autumn
% Fig. Species diversity vs chlorophyll
% Fig. Annual trends of biodiversity in WSC and EGC regions
% Fig. Ice coverage across months

%%Load Data
clearvars
close all
% %JobID = 'StationsGeneraJaccard'; %group by genera and use Jaccard as similarity measure
% JobID = 'StationsSpeciesJaccard'; %group by species and use Jaccard as similarity measure
% %JobID = 'StationsSpeciesJaccardNoMetazoa'; %the same as StationsSpeciesJaccard but excluding all Metazoa species
% %JobID = 'StationsGeneraJaccard2023'; %group by species and use Jaccard as similarity measure
% %JobID = 'StationsGeneraJaccard2023NoMetazoa'; %group by species and use Jaccard as similarity measure
% %JobID = 'StationsSpeciesJaccard2023'; %group by species and use Jaccard as similarity measure
%
% HGP = HG_GetParams(JobID);
%
% %to update data run the following
% %HG_DT_getCruisesDetails % to update dates of cruises
% %HG_DT_prepare_samples %to link samples with dates and env values
%
% [Data, DI] = DT_LoadData(HGP);
% %HGP.topGroupName  = 'Phylum';
% %Load samples
% dSamples = Data.dSamplesNorm;
% tSamples = Data.tSamplesNorm;
% idxSamplCols = DI.idxSamplCols;
% SamplNames = DI.SamplNames;
%
% %Load predictors
% tStPredictors = Data.tStPredictors;
%
% %species traits
% tTraits = Data.tTraits;


%%Load Data
clearvars
close all

%Load samples
tSamples = readtable('..\GitHub\hausgarten\data\Bio.xlsx');
idxSamplCols = 8:width(tSamples);
SamplNames = tSamples.Properties.VariableNames(idxSamplCols);
dSamples = tSamples{:, idxSamplCols};
tSamples.Species = string(tSamples.Species);
tSamples.Phylum = string(tSamples.Phylum);

%Load predictors
tStPredictors = readtable('..\GitHub\hausgarten\data\Env.xlsx');
tTraits = readtable('..\GitHub\hausgarten\data\Traits.xlsx');

HGP.topGroupName = 'Species';

%define the grouping variables
day_step = 21; %step of the day of year
tStPredictors.indDay = round(tStPredictors.doy/day_step)*day_step;
tStPredictors.indDepth = HG_isdeep(tStPredictors.Depth);
tStPredictors.indEast = HG_iseast(tStPredictors.Lon);


%%Remove EG4 station  (35 records)
%processEG4Station = 'ExcludeEG4';
%processEG4Station = 'EG4 only';
processEG4Station = '';  %include all data
switch processEG4Station
    case 'ExcludeEG4'
        indEG4 = ~strcmp(tStPredictors.HGStation, 'EG4');
        tStPredictors = tStPredictors(indEG4, :);
        dSamples = dSamples(:, indEG4);
        idxSamplCols = idxSamplCols(indEG4);
        tSamples = tSamples(:, [1:8, idxSamplCols]);
        idxSamplCols = 9:size(tSamples, 2);
        SamplNames = tSamples.Properties.VariableNames(idxSamplCols);
    case 'EG4 only'
        indEG4 = strcmp(tStPredictors.HGStation, 'EG4') | tStPredictors.indEast==1;
        tStPredictors = tStPredictors(indEG4, :);
        dSamples = dSamples(:, indEG4);
        idxSamplCols = idxSamplCols(indEG4);
        tSamples = tSamples(:, [1:8, idxSamplCols]);
        idxSamplCols = 9:size(tSamples, 2);
        SamplNames = tSamples.Properties.VariableNames(idxSamplCols);
    otherwise
        %do nothing
end


%find x most abundant families

%find mean abundance of each species across samples
meanAbundance = mean(dSamples, 2);
%group mean abundance by the HGP.topGroupName and sort them
[indMainFams, sMainFamNames] = f_GetMostAbundant(meanAbundance, tTraits{:, HGP.topGroupName});



%%find mean for each HGP.topGroupName in dSamples  (species x samples )

%1. Find sum for each group for each sample
meanFamAbund = grpstats([tSamples(:, HGP.topGroupName), tSamples(:, idxSamplCols)], HGP.topGroupName, {'sum'});
meanFamAbund.GroupCount = [];
topGroupNames = meanFamAbund{:, HGP.topGroupName};
%transpose meanFamAbund to make statistics in samples
meanFamAbundSmpl = meanFamAbund{:, 2:end}';  %HGP.topGroupName x samples
%remove spaces and 'g_' from names
% remove all spaces and underscore
topGroupNames = f_RemoveSpacesAndPrefix(topGroupNames);


%% Fitting species trends selected West/East Shallow/Deep
%  and finding the change in diversity
iFgNr = 50;
[iFgNr] = HG_sd_CalcNPlot('FindAndSaveSignSpeciesTrends', ...
    struct('tStPredictors', tStPredictors,  'tTraits', tTraits, 'meanFamAbundSmpl', meanFamAbundSmpl), iFgNr);

%plot correlations of chl and T with Richness and Simpson index
[iFgNr, Results] = HG_sd_CalcNPlot('PlotSummerCorrelations', ...
    struct('tStPredictors', tStPredictors,  'tTraits', tTraits, 'meanFamAbundSmpl', meanFamAbundSmpl), iFgNr);

%Temperature statistics
Results.Temp

%% plot distribution of orders by months /depth/east west
topGroupName = 'Phylum'; topGroupPrefix = '^p_ ';
tSamples{:, topGroupName} = cellfun(@(x) regexprep(x, topGroupPrefix, ''), tSamples{:, topGroupName}, 'UniformOutput', false);
tSamples{:, topGroupName} = f_RemoveSpacesAndPrefix(tSamples{:, topGroupName});
[iFgNr, Results] = HG_sd_CalcNPlot('plotRichnessDistributionsErrorOverYear', struct('tSamples', tSamples, 'idxSamplCols', idxSamplCols, ...
    'tStPredictors', tStPredictors, 'topGroupName', topGroupName), iFgNr);



%% Plot richness on temperature
[iFgNr, Results] = HG_sd_CalcNPlot('PlotRichnessOnTSummer', ...
    struct('tStPredictors', tStPredictors,  'tTraits', tTraits, 'meanFamAbundSmpl', meanFamAbundSmpl), iFgNr);



%% plot changes in diversity of the most rich phylas in summer as a function of year
topGroupName = 'Phylum'; topGroupPrefix = '^p_ ';
tSampleslocal = tSamples;
tSampleslocal{:, topGroupName} = cellfun(@(x) regexprep(x, topGroupPrefix, ''), tSampleslocal{:, topGroupName}, 'UniformOutput', false);
tSampleslocal{:, topGroupName} = f_RemoveSpacesAndPrefix(tSampleslocal{:, topGroupName});

divSimpson = f_DiversityMetrics(tSamples{:, idxSamplCols}, [], 'SimpsonESN', [], 1);
tStPredictors.sampleRichness = divSimpson';
%divSimpson = f_DiversityMetrics(tSamples{:, idxSamplCols}, [], 'Richness', [], 1);
tStPredictors.sampleRichness2 = sum(tSamples{:, idxSamplCols}>0, 1)';


iFgNr = HG_sd_CalcNPlot('plotSummerRichnessDistributions', struct('tSamples', tSampleslocal, 'idxSamplCols', idxSamplCols, ...
    'tStPredictors', tStPredictors, 'topGroupName', topGroupName, 'tTraits', tTraits, 'meanFamAbundSmpl', meanFamAbundSmpl), iFgNr);
tSampleslocal = [];


%% 2. Find mean value for given lon index, depth index and day index
%[meanDayDepthLonAbund, tDepthLonday] = grpstats(meanFamAbundSmpl, tStPredictors{:, {'indDepth', 'indEast', 'indDay'}}, {'median', 'gname'});
%find mean abundance for each groups

[meanDayDepthLonAbund, tDepthLonday] = grpstats(meanFamAbundSmpl, tStPredictors{:, {'indDepth', 'indEast', 'indDay'}}, {'mean', 'gname'});
tDepthLonday = cellfun(@str2double, tDepthLonday); %convert depth to double
tDepthLonday =  array2table(tDepthLonday);
tDepthLonday.Properties.VariableNames = {'indDepth', 'indEast', 'indDay'};

meanDayDepthLonAbund = array2table(meanDayDepthLonAbund);
meanDayDepthLonAbund.Properties.VariableNames = topGroupNames;
% meanDayDepthLonAbund = movevars(meanDayDepthLonAbund, "Others");
topGroupNames = meanDayDepthLonAbund.Properties.VariableNames;
%save a temporal dataset
%writenewtable(meanDayDepthLonAbund, 'tmp\meanDayDepthLonAbund.xls')
%writenewtable(tDepthLonday, 'tmp\tDepthLonday.xls')

%%Filter shallow east

indCombinations = [ 0, 0; 0, 1; 1, 0; 1, 1];  %E/W; Shallow/Deep
Titles = [ "EGC, <30m", "EGC, \geq 30m", "WSC, <30", "WSC, \geq 30m"];
MaxTayaPerGroup =8;
AllSpUnique = {};

% Calculate the thirds of observed period
% dayRange = range(TDayFiltered.indDay);
% firstThird = min(TDayFiltered.indDay) + dayRange / 3;
% secondThird = min(TDayFiltered.indDay) + 2 * dayRange / 3;
DayRanges = linspace(min(tDepthLonday.indDay), max(tDepthLonday.indDay), 4);  %define the boundaries
for iInds = 1:height(indCombinations )
    %select date for given location and depth
    ind = tDepthLonday.indDepth == indCombinations(iInds, 2) & tDepthLonday.indEast == indCombinations(iInds, 1);
    %get groups of spring, summer, and autumn species
    [groupedTables{iInds}, AllSpecies] = HG_sd_AvgDynamics_getgroups(meanDayDepthLonAbund(ind, :) ,  tDepthLonday(ind, :), DayRanges,  MaxTayaPerGroup);
    AllSpUnique = [AllSpUnique, AllSpecies];
end
AllSpUnique = unique(AllSpUnique)';  %create a list of unique species identifications (genera, class, phyla etc)

tSamples(:, HGP.topGroupName) = f_RemoveSpacesAndPrefix(tSamples{:, HGP.topGroupName});
tSamples(:, 'Phylum') = f_RemoveSpacesAndPrefix(tSamples{:, 'Phylum'});
tSamples(:, 'Class') = f_RemoveSpacesAndPrefix(tSamples{:, 'Class'});
tSamples(:, 'Genus') = f_RemoveSpacesAndPrefix(tSamples{:, 'Genus'});
tSamples(:, 'Species') = f_RemoveSpacesAndPrefix(tSamples{:, 'Species'});


%%
%assign colors automatically
[DictsColrs] = HG_DT_ReadSpeciesColors(AllSpUnique);
%add phyla and class to the species name
tSamplestmp = tSamples;
tSamplestmp.ASV = tSamples.Species;
DictsColrs = HG_sg_aux_GetNewNames(DictsColrs, tSamplestmp);


fg1 = f_MakeFigure(1, [-1, -1, 1461, 850]);
clf
%create tiled layout
%tiledlayout(3, 4, "TileSpacing","tight", "Padding","tight");
tiledlayout(3, 4, "TileSpacing","compact", "Padding","tight");
PlotAxes = arrayfun(@(x) nexttile, 1:12, 'UniformOutput', false);
for iInds = 1:height(indCombinations )
    %define index of subplots
    ind = tDepthLonday.indDepth == indCombinations(iInds, 2) & tDepthLonday.indEast == indCombinations(iInds, 1);
    PlotInds = [iInds, iInds+4, iInds+8];
    %plot results
    AddYLabel = iInds==1;
    HG_sd_AvgDynamics_plotgroups(Titles(iInds), PlotAxes(PlotInds), groupedTables{iInds}, tDepthLonday(ind, :), DictsColrs, AddYLabel)
end
AddLetters2Plots('Location',   'SouthWest', 'VShift', -0.03)


