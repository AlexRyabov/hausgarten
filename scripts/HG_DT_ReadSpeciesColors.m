function [DictsColrs] = HG_DT_ReadSpeciesColors(fileNameOrSpeciesList)

if iscell(fileNameOrSpeciesList)
    %use the list of species names
    AllSpUnique = fileNameOrSpeciesList;
    %replace underscores wiht spaces
    AllSpUniqueNames =    cellfun(@(x) regexprep(x, '_', ' '), AllSpUnique , 'UniformOutput', false);
    %speciesColor = maxdistcolor(length(AllSpUnique),@sRGB_to_OKLab);
    %speciesColor = slanCM('colorcube', length(AllSpUnique)+2); speciesColor = speciesColor(2:end-1, :);
    %speciesColor = slanCM('glasbey', length(AllSpUnique));
    speciesColor = distinguishable_colors(length(AllSpUnique), {'w','k'});
    rng(4)
    speciesColor = speciesColor(randperm( length(AllSpUnique)), :)
    DictsColrs =  dictionary(AllSpUnique(1), struct('speciesColor', speciesColor(1, :), 'NewName', AllSpUniqueNames{1}));
    for i = 2:numel(AllSpUnique)
        DictsColrs(AllSpUnique(i)) =  struct('speciesColor', speciesColor(i, :), 'NewName', AllSpUniqueNames{i});
    end
    DictsColrs({'Others'}) =  struct('speciesColor', [1,1,1]*0.75, 'NewName', 'Others');
else

    % Define the file path to the Excel file
    fileName = fileNameOrSpeciesList;

    % Read data from the Excel file
    [num, txt, raw] = xlsread(fileName);

    % Get the column index of 'Genus' and 'Phylum'
    genusColumn = find(strcmpi(txt(1,:), 'Genus'));
    newNameColumn = find(strcmpi(txt(1,:), 'Name2Plot'));
    phylumColumn = find(strcmpi(txt(1,:), 'Phylum'));

    % Get the species names and corresponding background colors
    speciesNames = txt(2:end, genusColumn);
    speciesNewNames = txt(2:end, newNameColumn);
    speciesNewNames  = cellfun(@(x) regexprep(x, '_', ' '), speciesNewNames , 'UniformOutput', false);


    backgroundColors = zeros(size(speciesNames));

    % Create an ActiveX server to interact with Excel
    excel = actxserver('Excel.Application');
    excel.Visible = true; % Show Excel application

    % Open the workbook
    workbook = excel.Workbooks.Open(fullfile(pwd, fileName));
    sheet = workbook.Sheets.Item(1);
    speciesColor = NaN(numel(speciesNames), 3);
    % Loop through each species name
    % figure(1)
    % clf
    for i = 1:numel(speciesNames)
        % Find the cell corresponding to the species name
        cell = sheet.Range([char('A' + phylumColumn - 1), num2str(i+1)]);

        % Get the background color of the cell
        excelColor = cell.Interior.Color;
        red = mod(excelColor, 256);
        green = mod(floor(excelColor / 256), 256);
        blue = mod(floor(excelColor / (256^2)), 256);

        % Normalize the color components to the range [0, 1]
        rgb = [red, green, blue] / 255;

        speciesColor(i, :) = rgb;
        % plot([1, 2], [-i, -i], 'LineWidth',3, 'Color',rgb)
        % hold on
    end

    % Close Excel
    excel.Quit;
    excel.delete;

    speciesColor = maxdistcolor(length(speciesNewNames),@sRGB_to_OKLab);

    DictsColrs =  dictionary(speciesNames(1), struct('speciesColor', speciesColor(1, :), 'NewName', speciesNewNames{1}));
    for i = 2:numel(speciesNames)
        DictsColrs(speciesNames(i)) =  struct('speciesColor', speciesColor(i, :), 'NewName', speciesNewNames{i});
    end
    DictsColrs({'Others'}) =  struct('speciesColor', [1,1,1]*0.75, 'NewName', 'Others');

end

