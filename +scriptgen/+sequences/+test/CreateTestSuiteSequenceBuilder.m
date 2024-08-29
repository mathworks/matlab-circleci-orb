classdef CreateTestSuiteSequenceBuilder < scriptgen.CodeBuilder
    % Copyright 2020 The MathWorks, Inc.
    
    properties
        CodeProvider = scriptgen.CodeProvider.default()
        SuiteName = 'suite'
        SelectByFolder = {}
        SelectByTag = ''
        CircleCITestFiles = ''
    end
    
    methods
        function set.CodeProvider(obj, value)
            validateattributes(value, {'scriptgen.CodeProvider'}, {'scalar'});
            obj.CodeProvider = value;
        end
        
        function set.SuiteName(obj, value)
            scriptgen.internal.validateTextScalar(value);
            obj.SuiteName = value;
        end
        
        function set.SelectByFolder(obj, value)
            scriptgen.internal.validateTextArray(value);
            obj.SelectByFolder = value;
        end
        
        function set.SelectByTag(obj, value)
            scriptgen.internal.validateTextScalar(value);
            obj.SelectByTag = value;
        end

        function set.CircleCITestFiles(obj, value)
            scriptgen.internal.validateText(value);
            obj.CircleCITestFiles = value;
        end    
    end
end

