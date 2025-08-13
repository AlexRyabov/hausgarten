function similarityTable = hg_sd_Richness_f_TaxaSimilarity(tLongSamplesEvnPhylaSpec)
% hg_sd_Richness_f_TaxaSimilarity - Calculate Jaccard and Morisita-Horn index 
% between East and West regions for each taxonomic group based on species composition.
%
% Input:
%   tLongSamplesEvnPhylaSpec - Table with columns:
%       - GroupTaxa: taxonomic group
%       - Genus: species/genus identifiers
%       - indEast: logical flag for East (true) or West (false)
%       - mean_FloatAbundance: average abundance of the taxon
%
% Output:
%   similarityTable - Table with the following columns:
%       - GroupTaxa: name of taxonomic group
%       - nEast: number of species in East
%       - nWest: number of species in West
%       - nUnion: number of species present in either region
%       - nIntersection: number of species shared between regions
%       - JaccardIndex: intersection / union (presence-absence based)
%       - MorisitaHornIndex: abundance-based similarity index

% Unique taxonomic groups
groupTaxaList = unique(tLongSamplesEvnPhylaSpec.GroupTaxa);
n = numel(groupTaxaList);

% Preallocate result arrays
GroupTaxa = strings(n,1);
nEast = zeros(n,1);
nWest = zeros(n,1);
nUnion = zeros(n,1);
nIntersection = zeros(n,1);
JaccardIndex = nan(n,1);
MorisitaHornIndex = nan(n,1);

for i = 1:n
    currentGroup = groupTaxaList{i};
    GroupTaxa(i) = currentGroup;

    % Filter rows for current group
    groupData = tLongSamplesEvnPhylaSpec(strcmp(tLongSamplesEvnPhylaSpec.GroupTaxa, currentGroup), :);

    % Skip group if no data in either region
    if ~any(groupData.indEast) || ~any(~groupData.indEast)
        continue
    end

    % Aggregate mean abundance by Genus and Region
    abundanceTable = grpstats(groupData(:, {'Genus', 'indEast', 'mean_FloatAbundance'}), ...
                              {'Genus', 'indEast'}, 'mean');
    abundanceTable.Properties.VariableNames{'mean_mean_FloatAbundance'} = 'Abundance';

    % Convert to wide format: one row per Genus, columns for East and West
    wideTable = unstack(abundanceTable, 'Abundance', 'indEast');

    % Fill missing values with 0 (absent)
    X = wideTable{:, {'x0', 'x1'}}; % Columns: false (West), true (East)
    X(isnan(X)) = 0;

    % ----- JACCARD -----
    presentWest = X(:,1) > 0;
    presentEast = X(:,2) > 0;
    intersection = presentWest & presentEast;
    unionPresence = presentWest | presentEast;

    nWest(i) = sum(presentWest);
    nEast(i) = sum(presentEast);
    nIntersection(i) = sum(intersection);
    nUnion(i) = sum(unionPresence);

    if nUnion(i) > 0
        JaccardIndex(i) = nIntersection(i) / nUnion(i);
    end

    % ----- MORISITA-HORN -----
    X_MH = X';  % Rows = [West; East], Columns = species
    mhIndex = f_MorisitaHorn(X_MH, true);
    MorisitaHornIndex(i) = mhIndex(1, 2);
end

% Compile results into table
similarityTable = table(GroupTaxa, nEast, nWest, nUnion, nIntersection, ...
                        JaccardIndex, MorisitaHornIndex);

% Sort by Jaccard index
similarityTable = sortrows(similarityTable, "MorisitaHornIndex");

end


% 
% function jaccardTable = hg_sd_Richness_f_TaxaSimilarity(tLongSamplesEvnPhylaSpec)
% 
% % computeJaccardIndex - Calculate Jaccard index for species composition 
% % differences between two regions (East and West) across taxonomic groups.
% % (tLongSamplesEvnPhylaSpec)
% 
% % Get unique group taxa
% groupTaxaList = unique(tLongSamplesEvnPhylaSpec.GroupTaxa);
% n = numel(groupTaxaList);
% 
% % Prepare result arrays
% GroupTaxa = strings(n,1);
% nEast = zeros(n,1);
% nWest = zeros(n,1);
% nUnion = zeros(n,1);
% nIntersection = zeros(n,1);
% JaccardIndex = zeros(n,1);
% 
% for i = 1:n
%     currentGroup = groupTaxaList{i};
%     GroupTaxa(i) = currentGroup;
% 
%     % Subset for this group
%     groupData = tLongSamplesEvnPhylaSpec(strcmp(tLongSamplesEvnPhylaSpec.GroupTaxa, currentGroup), :);
% 
%     % Get unique species for each region
%     speciesEast = unique(groupData.Genus(groupData.indEast));
%     speciesWest = unique(groupData.Genus(~groupData.indEast));
%     %grpstat(groupData, [indEast, Genus, ])
% 
%     % Calculate set metrics
%     unionSpecies = union(speciesEast, speciesWest);
%     interSpecies = intersect(speciesEast, speciesWest);
% 
%     % Store counts
%     nEast(i) = numel(speciesEast);
%     nWest(i) = numel(speciesWest);
%     nUnion(i) = numel(unionSpecies);
%     nIntersection(i) = numel(interSpecies);
%     JaccardIndex(i) = nIntersection(i) / nUnion(i);  % Will be NaN if union is empty
% end
% 
% % Create result table
% jaccardTable = table(GroupTaxa, nEast, nWest, nUnion, nIntersection, JaccardIndex);
% jaccardTable = sortrows(jaccardTable, "JaccardIndex");
% end
