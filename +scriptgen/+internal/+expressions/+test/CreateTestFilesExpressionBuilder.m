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
            
            % erase function uses R2016b or later
            obj.TestFiles = erase(obj.TestFiles, '.m');
            quotedTestFiles = cellfun(@(x) ['''' x ''''], obj.TestFiles, 'UniformOutput', false);
            testFilesStr = ['{' strjoin(quotedTestFiles, ', ') '}'];
            text = sprintf('TestFiles = %s;', testFilesStr);
            patternsStr = 'patterns = strcat(TestFiles, ''/*'');';
            suiteStr = 'suite = selectIf(suite, ''Name'', patterns);';
            fullText = sprintf('%s\n%s\n%s', text, patternsStr, suiteStr);
            
            expression = Expression(fullText);
        end
    end
end

