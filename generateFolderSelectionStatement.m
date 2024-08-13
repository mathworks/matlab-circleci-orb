function finalStatement= generateFolderSelectionStatement(statement)
import scriptgen.internal.unquoteText;
import scriptgen.internal.isAbsolutePath;

statement = strtrim(strsplit(statement, {';', ':'}));
statement = cellfun(@(t) ['''' t ''''], strrep(statement, '''', ''''''), 'UniformOutput', false);

constraints = {}; 

for i = 1:numel(statement)
    folder = statement{i};

    if ~strcmp(folder, unquoteText(folder)) && ~isAbsolutePath(unquoteText(folder))
        constraint = sprintf('StartsWithSubstring(fullfile(pwd, %s))', folder);
    else
        constraint = sprintf('StartsWithSubstring(%s)', folder);
    end
    
    constraints{end+1} = constraint; %#ok<AGROW>
end

statement = sprintf('HasBaseFolder(%s)', strjoin(constraints, ' | '));
finalStatement = sprintf('suite = suite.selectIf(%s);', statement);
end

