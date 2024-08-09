classdef CreateTestFilesExpressionBuilder < scriptgen.CodeBuilder
    % Copyright 2020 The MathWorks, Inc.
    
    properties
        TestFiles = {}
    end
    
    methods
        function set.TestFiles(obj, value)
            scriptgen.internal.validateTextArray(value);
            obj.TestFiles = value;
        end
    end
end