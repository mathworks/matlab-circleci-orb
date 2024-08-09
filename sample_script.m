function finalText= sample_script(text)
import scriptgen.internal.unquoteText;
import scriptgen.internal.isAbsolutePath;

text = strtrim(strsplit(text, {';', ':'}));
text = cellfun(@(t) ['''' t ''''], strrep(text, '''', ''''''), 'UniformOutput', false);

constraints = {}; 

for i = 1:numel(text)
    folder = text{i};

    if ~strcmp(folder, unquoteText(folder)) && ~isAbsolutePath(unquoteText(folder))
        constraint = sprintf('StartsWithSubstring(fullfile(pwd, %s))', folder);
    else
        constraint = sprintf('StartsWithSubstring(%s)', folder);
    end
    
    constraints{end+1} = constraint; %#ok<AGROW>
end

Text = sprintf('HasBaseFolder(%s)', strjoin(constraints, ' | '));
finalText = sprintf('suite = suite.selectIf(%s);', Text);
end

