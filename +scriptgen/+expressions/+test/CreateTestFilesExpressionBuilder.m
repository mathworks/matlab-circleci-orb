classdef CreateTestFilesExpressionBuilder < scriptgen.CodeBuilder
    % Copyright 2020 The MathWorks, Inc.
    
    properties
        CircleCITestFiles = {}
    end
    
    methods
        function set.CircleCITestFiles(obj, value)
            scriptgen.internal.validateTextArray(value);
            obj.CircleCITestFiles = value;
        end
    end
end