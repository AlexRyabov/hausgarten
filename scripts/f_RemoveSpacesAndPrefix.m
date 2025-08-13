function topGroupNames = f_RemoveSpacesAndPrefix(topGroupNames)
%remove spaces and prefixes 'g_' from names

topGroupNames = cellfun(@(x) strrep(x, ' ', ''), topGroupNames, 'UniformOutput', false);
% Replace 'g_' at the beginning of strings in the cell array
topGroupNames = cellfun(@(x) regexprep(x, '^s_', 's-'), topGroupNames, 'UniformOutput', false);
topGroupNames = cellfun(@(x) regexprep(x, '^g_', 'g-'), topGroupNames, 'UniformOutput', false);
topGroupNames = cellfun(@(x) regexprep(x, '^f_', 'f-'), topGroupNames, 'UniformOutput', false);
topGroupNames = cellfun(@(x) regexprep(x, '^o_', 'o-'), topGroupNames, 'UniformOutput', false);
topGroupNames = cellfun(@(x) regexprep(x, '^c_', 'c-'), topGroupNames, 'UniformOutput', false);
topGroupNames = cellfun(@(x) regexprep(x, '^p_', 'p-'), topGroupNames, 'UniformOutput', false);
%added 23.07.24 to remove all underscores. Might cause some problems 
%topGroupNames = cellfun(@(x) regexprep(x, '_', ' '), topGroupNames, 'UniformOutput', false);


