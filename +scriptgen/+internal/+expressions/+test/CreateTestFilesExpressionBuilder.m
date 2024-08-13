classdef CreateTestFilesExpressionBuilder < scriptgen.expressions.test.CreateTestFilesExpressionBuilder ...
        & scriptgen.internal.mixin.VersionDependent
    % Copyright 2020 The MathWorks, Inc.
    
    properties (Constant, Access = protected)
        MinSupportedVersion = scriptgen.internal.Version.forRelease('R2014a')
    end
    
    methods 
        function expression = build(obj)
            import scriptgen.internal.unquoteText;
            import scriptgen.internal.isAbsolutePath;
            import scriptgen.Expression;
            
            quotedTestFiles = cellfun(@(x) ['''' x ''''], obj.CircleCITestFiles, 'UniformOutput', false);
            testFilesStr = ['{' strjoin(quotedTestFiles, ', ') '}'];
            text = sprintf('CircleCITestFiles = %s;', testFilesStr);
            patternsStr = 'patterns = strcat(CircleCITestFiles, ''/*'');';
            suiteStr = 'suite = selectIf(suite, ''Name'', patterns);';
            fullText = sprintf('%s\n%s\n%s', text, patternsStr, suiteStr);
            
            expression = Expression(fullText);
        end
    end
end

