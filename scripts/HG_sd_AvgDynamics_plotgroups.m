function HG_sd_AvgDynamics_plotgroups(Title, PlotAxes, groupedTables, tDepthLonday, DictsColrs, AddYLabel)


ylims = [0, 0.9];
%xlims = [140, 280];
xlims = [5.5, 10.5];

% Number of groups
numGroups = length(groupedTables);

% Iterate over each group and create a subplot for each
for i = 1:numGroups
    axes(PlotAxes{i}); % Set current axes to the i-th subplot    
    % Extract data for current group
    currentGroupData = groupedTables{i};
    if size(currentGroupData, 1) == 0
        continue
    end
    currentGroupData = currentGroupData(:, end:-1:1);
    % Prepare data for stacked plot
    stackedData = table2array(currentGroupData);
    days =tDepthLonday.indDay/365*12+1;
    
   
    %Change 'Others(xx)' to others. 
    if startsWith(currentGroupData.Properties.VariableNames{1}, "Others")
        OldOthers = currentGroupData.Properties.VariableNames{1};
        currentGroupData.Properties.VariableNames{1} = 'Others';
        cm = [DictsColrs(currentGroupData.Properties.VariableNames').speciesColor];
        DictsColrs({'Others'}).NewName = OldOthers;
        NewNames = {DictsColrs(currentGroupData.Properties.VariableNames(end:-1:1)).NewName};
        % currentGroupData.Properties.VariableNames{1} = OldOthers;
    else
        cm = [DictsColrs(currentGroupData.Properties.VariableNames').speciesColor];
         NewNames = {DictsColrs(currentGroupData.Properties.VariableNames(end:-1:1)).NewName};
    end
        cm = reshape(cm, 3, numel(cm)/3)';
    % Create stacked area plot
    ar = area(days, stackedData, 'LineStyle', 'none');
    colororder(gca, cm);

    ylim(ylims);
    xlim(xlims);
    
    % Add legends and titles
    %Change the order to get the legend from top to bottom


    lg = legend(ar(end:-1:1), NewNames, 'Location', 'best', 'Color','none', 'EdgeColor', 'none', FontSize=8);
    if i == 1
        title(Title);
    end
    if i == 3
        xlabel('Month');
    end
    if AddYLabel
        ylabel('ASV rel. abundance');
    end
end






