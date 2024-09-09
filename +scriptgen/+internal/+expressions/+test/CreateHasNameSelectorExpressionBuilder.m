classdef CreateHasNameSelectorExpressionBuilder < scriptgen.expressions.test.CreateHasNameSelectorExpressionBuilder ...
        & scriptgen.internal.mixin.VersionDependent
    % Copyright 2024 The MathWorks, Inc.
    
    properties (Constant, Access = protected)
        MinSupportedVersion = scriptgen.internal.Version.forRelease('R2020a')
    end
    
    methods 
        function expression = build(obj)
            import scriptgen.Expression;
            
            testFiles = cellfun(@(x) ['''' x ''''], obj.SelectByName, 'UniformOutput', false);
            testFiles = ['{' strjoin(testFiles, ', ') '}'];
            text = sprintf('names = %s;',testFiles);
            suiteStr = 'suite = suite.selectIf(''Name'', names);';
            fullText = sprintf('%s\n%s', text, suiteStr);
            
            expression = Expression(fullText);
        end
    end
end

