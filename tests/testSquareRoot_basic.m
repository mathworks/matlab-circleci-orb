classdef testSquareRoot_basic < matlab.unittest.TestCase
   
    methods (TestClassSetup)
        function addTestContentToPath(testCase)
            addpath(fullfile(fileparts(pwd),'source'));
        end
    end       
    
    
    methods (Test)
        function testValues(testCase)
            testCase.verifyEqual(squareRoot(16),4);
            testCase.verifyEqual(squareRoot(81),9);            
        end
        
    end
   
end
