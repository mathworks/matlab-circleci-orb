classdef BaseClassWithMethodsToBeOverridden < matlab.unittest.TestCase
    
    % Because MCOS returns methods in the reverse of the order they're
    % defined in, we define some of the methods to be overridden first and
    % some of the methods to be overridden second. Because of the
    % subclass/superclass relationship, this order will not matter; the
    % class hierarchy will impose a stronger constraint that superclass
    % setup methods are called first.
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (TestClassSetup)
        % Method to be overridden defined first
        function commonTestClassSetup(testCase)
            testCase.log('commonTestClassSetup');
        end
        function baseTestClassSetup(testCase)
            testCase.log('baseTestClassSetup');
        end
    end
    
    methods (TestClassTeardown)
        % Method to be overridden defined second
        function baseTestClassTeardown(testCase)
            testCase.log('baseTestClassTeardown');
        end
        function commonTestClassTeardown(testCase)
            testCase.log('commonTestClassTeardown');
        end
    end
    
    methods (TestMethodSetup)
        % Method to be overridden defined first
        function commonTestMethodSetup(testCase)
            testCase.log('commonTestMethodSetup');
        end
        function baseTestMethodSetup(testCase)
            testCase.log('baseTestMethodSetup');
        end
    end
    
    methods (TestMethodTeardown)
        % Method to be overridden defined second
        function baseTestMethodTeardown(testCase)
            testCase.log('baseTestMethodTeardown');
        end
        function commonTestMethodTeardown(testCase)
            testCase.log('commonTestMethodTeardown');
        end
    end
    
    methods (Test)
        function test1(testCase)
            testCase.log('test1');
        end
    end
end

