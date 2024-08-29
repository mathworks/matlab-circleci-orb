classdef CreateHasNameSelectorExpressionBuilder < scriptgen.CodeBuilder
    % Copyright 2020 The MathWorks, Inc.
    
    properties
        SelectByName = ''
    end
    
    methods
        function set.SelectByName(obj, value)
            scriptgen.internal.validateText(value);
            obj.SelectByName = value;
        end
    end
end