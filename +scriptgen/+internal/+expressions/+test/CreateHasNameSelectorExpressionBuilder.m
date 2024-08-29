classdef CreateHasNameSelectorExpressionBuilder < scriptgen.expressions.test.CreateHasNameSelectorExpressionBuilder ...
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
            
            text = sprintf('names = %s;', obj.SelectByName);
            suiteStr = 'suite = suite.selectIf(''Name'', names);';
            fullText = sprintf('%s\n%s', text, suiteStr);
            
            expression = Expression(fullText);
        end
    end
end

