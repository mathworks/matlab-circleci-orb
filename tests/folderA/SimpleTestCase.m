classdef SimpleTestCase < matlab.unittest.TestCase
    % Basic simple testcase class meant to ensure that TestRunner correctly
    % runs TestCase tests
    
    % Copyright 2012 The MathWorks, Inc.
    methods(TestClassSetup)
        function beforeClass(testCase)
            testCase.callAllPassingQualifications();
        end
    end
    methods(TestClassTeardown)
        function afterClass(testCase)
            testCase.callAllPassingQualifications();
        end
    end
    methods(TestMethodSetup)
        function before(testCase)
            testCase.callAllPassingQualifications();
        end
    end
    methods(TestMethodTeardown)
        function after(testCase)
            testCase.callAllPassingQualifications();
        end
    end
    
    % lets have two tests to ensure correct invocation counts of class level &
    % method level setup
    methods(Test)
     
        function test1(testCase)
            testCase.callAllPassingQualifications();
        end

        function test2(testCase)
            testCase.callAllPassingQualifications();
        end
    end
    
    methods
        function helperMethod(~)
        end
        function callAllPassingQualifications(testCase)
            testCase.verifyTrue(true);
            testCase.assertTrue(true);
            testCase.fatalAssertTrue(true);
            testCase.assumeTrue(true);
        end
            
    end
            
    
end

