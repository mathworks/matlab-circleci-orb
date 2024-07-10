classdef tvalidateVerbosityInput < matlab.unittest.TestCase
     properties(TestParameter)
        ValidInputs = struct(...
            'Numeric',1,...
            'VerbosityEnum',matlab.unittest.Verbosity.Detailed,...
            'CharVec','Terse',...
            'String',"Verbose");
        
        InvalidInputs = createInvalidInputs()
     end
    
    
    methods (Test)       
        function positiveValidationTests(testCase,ValidInputs)
            validVerbosity = validateVerbosityInput(ValidInputs); % this should not error
            testCase.verifyClass(validVerbosity,'matlab.unittest.Verbosity');
        end
        function negativeValidationTests(testCase,InvalidInputs)
            import matlab.unittest.constraints.Throws
            testCase.verifyThat(@()validateVerbosityInput(...
                InvalidInputs.Input),Throws(InvalidInputs.ErrorID));
        end  
        
        function testReturnsValidVerbosityInstance(testCase)
            actValidVerbosity = validateVerbosityInput("Terse");
            expValidVerbosity = matlab.unittest.Verbosity.Terse;
            testCase.verifyEqual(actValidVerbosity,expValidVerbosity);
        end
    end
end
function out = validateVerbosityInput(varargin)
out = matlab.unittest.internal.validateVerbosityInput(varargin{:});
end
function cases = createInvalidInputs()
cases.InvalidTextVerbosity = struct(...
    'Input','InvalidValue',...
    'ErrorID','MATLAB:class:CannotConvert');

cases.InvalidNumericVerbosity = struct(...
    'Input',100,...
    'ErrorID','MATLAB:class:InvalidEnum');

cases.NonIntegerNumbers = struct(...
    'Input',2.5,...
    'ErrorID','MATLAB:class:InvalidEnum');

cases.NonScalarNumber = struct(...
    'Input',[1,2],...
    'ErrorID','MATLAB:expectedScalar');

cases.NonScalarText = struct(...
    'Input',["Verbose","Detailed"],...
    'ErrorID','MATLAB:expectedScalartext');

cases.InvalidType = struct(...
    'Input',{{'Terse','Concise'}},...
    'ErrorID','MATLAB:invalidType');
end
