classdef CreateHasNameSelectorExpressionBuilder < scriptgen.expressions.test.CreateHasNameSelectorExpressionBuilder ...
        & scriptgen.internal.mixin.VersionDependent
    % Copyright 2020 The MathWorks, Inc.
    
    properties (Constant, Access = protected)
        MinSupportedVersion = scriptgen.internal.Version.forRelease('R2020a')
    end
    
    methods 
        function expression = build(obj)
            import scriptgen.internal.unquoteText;
            import scriptgen.internal.isAbsolutePath;
            import scriptgen.Expression;
            
            TestFiles = cellfun(@(x) ['''' x ''''], obj.SelectByName, 'UniformOutput', false);
            TestFiles = ['{' strjoin(TestFiles, ', ') '}'];
            text = sprintf('names = %s;',TestFiles);
            suiteStr = 'suite = suite.selectIf(''Name'', names);';
            fullText = sprintf('%s\n%s', text, suiteStr);
            
            expression = Expression(fullText);
        end
    end
end

