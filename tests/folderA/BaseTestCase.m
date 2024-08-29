classdef BaseTestCase < matlab.unittest.TestCase
    % TestCase base class meant to ensure that method order respects class hierarchies
    % TestCase
    
    
    
    
    % Copyright 2011 The MathWorks, Inc.
    methods(TestClassSetup)
        function baseTestClassSetup(testCase)
            disp baseTestClassSetup
            testCase.addTeardown(@disp, 'baseTestClassSetupAddTeardown');
        end
        function baseTestClassSetup2(testCase)
            disp baseTestClassSetup
            testCase.addTeardown(@disp, 'baseTestClassSetupAddTeardown');
        end
    end
    methods(TestClassTeardown)
        function baseTestClassTeardown(testCase)
            disp baseTestClassTeardown
            testCase.addTeardown(@disp, 'baseTestClassTeardownAddTeardown');
        end
        function baseTestClassTeardown2(testCase)
            disp baseTestClassTeardown
            testCase.addTeardown(@disp, 'baseTestClassTeardownAddTeardown');
        end
    end
    methods(TestMethodSetup)
        function baseTestMethodSetup(testCase)
            disp baseTestMethodSetup
            testCase.addTeardown(@disp, 'baseTestMethodSetupAddTeardown');
        end
        function baseTestMethodSetup2(testCase)
            disp baseTestMethodSetup
            testCase.addTeardown(@disp, 'baseTestMethodSetupAddTeardown');
        end
    end
    methods(TestMethodTeardown)
        function baseTestMethodTeardown(testCase)
            disp baseTestMethodTeardown
            testCase.addTeardown(@disp, 'baseTestMethodTeardownAddTeardown');
        end
        function baseTestMethodTeardown2(testCase)
            disp baseTestMethodTeardown
            testCase.addTeardown(@disp, 'baseTestMethodTeardownAddTeardown');
        end
    end
    
    % lets have two tests to ensure correct invocation counts of class level &
    % method level setup
    methods(Test)
        
        function baseTest(testCase)
            disp baseTest
            testCase.addTeardown(@disp, 'baseTestAddTeardown');
        end
        
        function baseTest2(testCase)
            % Disp the same as the other test since test order is not defined
            disp baseTest
            testCase.addTeardown(@disp, 'baseTestAddTeardown');
        end
        
    end
    
    
end

