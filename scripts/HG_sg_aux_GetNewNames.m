function DictsColrs = HG_sg_aux_GetNewNames(DictsColrs, tSamples)
%update NewName to merge Phylum, Class and ASV name 

% Loop through each key in the dictionary
keys = DictsColrs.keys; % Get all keys from the dictionary

for i = 1:length(keys)
    key = keys{i}; % Get the current key
    key = f_RemoveSpacesAndPrefix({key});
    
    key = string(key{:});
    % Find the row in tSamples where tSamples.ASV equals the value of the key
    rowIdx = find(strcmp(tSamples.ASV, key));
    
    if ~isempty(rowIdx) % Check if a matching row is found
        % Extract the first two letters from Phylum and Class fields
        phylumPart = tSamples.Phylum{rowIdx}(1:2);
        classPart = tSamples.Class{rowIdx}(1:2);
        
        % Concatenate to form the new name
        %newName = strcat(phylumPart, '-', classPart, '-', extractAfter(regexprep(key, '_', ' '), 2));
        %newName = strcat(phylumPart, '.', classPart, '.', extractAfter(regexprep(key, '_', ' '), 2));
        %newName = extractAfter(regexprep(key, '_', ' '), 2);
        newName = regexprep(key, '_', ' ');
        %Remove X sp. , XX sp. etc 
        %newName = regexprep(newName,'\s+X+ sp\.?$', '');  %removes X sp. or X sp   (one X or more).

        % Assign this new name to the NewName field of the structure in the dictionary
        DictsColrs(keys(i)).NewName = char(newName);
    else
        warning('No match found for key: %s', key);
    end
end
