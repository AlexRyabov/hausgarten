function [groupedTables, AllSpecies] = HG_sd_AvgDynamics_getgroups(TFiltered , TDayFiltered, DayRanges, MaxSpeciesPerGroup)
% Load data (assuming the data is in two tables: 'TFiltered' the average
% species abundances for groups given in TDayFiltered  (the depth, longitude, and day indices)




% Initialize cell array to hold tables for each group
groupedTables = cell(3, 1);

% Assign species to early middle or late group based on max abundance day  
for i = 1:width(TFiltered)
    speciesData = TFiltered{:, i};
    [maxVal, maxIdx] = max(speciesData);
    maxDay = TDayFiltered.indDay(maxIdx);
    
    if maxDay <= DayRanges(2)
        groupNum = 1;
    elseif maxDay <= DayRanges(3)
        groupNum = 2;
    else
        groupNum = 3;
    end
    
    % Append species data to the appropriate group
    if isempty(groupedTables{groupNum})
        groupedTables{groupNum} = table(speciesData, 'VariableNames', TFiltered.Properties.VariableNames(i));
    else
        groupedTables{groupNum} = [groupedTables{groupNum}, table(speciesData, 'VariableNames', TFiltered.Properties.VariableNames(i))];
    end
end
%groupedTables contains average abundances of species in each group (early, middle, late)
% Sort species in each group by their mean abundance
AllSpecies = {};
for i = 1:length(groupedTables)
    if size(groupedTables{i}, 1) >0
        meanAbundances = varfun(@mean, groupedTables{i}, 'OutputFormat', 'uniform');
        [sortedMeans, sortOrder] = sort(meanAbundances, "descend");
        groupedTables{i} = groupedTables{i}(:, sortOrder);
        SpecNum = width(groupedTables{i});

        if SpecNum > MaxSpeciesPerGroup
            % Sum the abundances of the columns to be removed
            sumOfRemoved = sum(groupedTables{i}{:, MaxSpeciesPerGroup+1:end}, 2);

            % Retain only the first 4 columns
            groupedTables{i} = groupedTables{i}(:, 1:MaxSpeciesPerGroup);

            % Add the summed column as the new fifth column
            groupedTables{i}.SumOfRemoved = sumOfRemoved;
            groupedTables{i}.Properties.VariableNames{end} = ['Others(' NS(SpecNum-MaxSpeciesPerGroup) ')'];
            AllSpecies = [AllSpecies, groupedTables{i}.Properties.VariableNames{1:end-1}];
        else
            AllSpecies = [AllSpecies, groupedTables{i}.Properties.VariableNames{1:end}];
        end
    end
end

% 'groupedTables' now contains the three groups of tables, each sorted by mean species abundance
