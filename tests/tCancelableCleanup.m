classdef tCancelableCleanup < matlab.unittest.TestCase
    %tCancelableCleanup - Tests for matlab.unittest.internal.CancelableCleanup
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods(Test)
        function test_Construction(testCase)
            dummy = @dummySubFunc;
            cleanupObj = CancelableCleanup(dummy);
            testCase.verifyEqual(cleanupObj.Task,dummy);
            testCase.verifyFalse(cleanupObj.Cancelled);
        end
        
        function test_delete_WithoutCancel(testCase)
            value = false;
            function makeValueTrue()
                value = true;
            end
            cleanupObj = CancelableCleanup(@makeValueTrue);
            delete(cleanupObj);
            testCase.verifyTrue(value);
        end
        
        function test_delete_WithCancel(testCase)
            value = false;
            function makeValueTrue()
                value = true;
            end
            func = @makeValueTrue;
            cleanupObj = CancelableCleanup(func);
            cleanupObj.cancel();
            testCase.verifyTrue(cleanupObj.Cancelled);
            testCase.verifyEqual(cleanupObj.Task,func);
            delete(cleanupObj);
            testCase.verifyFalse(value);
        end
        
        function test_cancelAndInvoke(testCase)
            
            function makeValueTrue
                value = true;
            end
            cleanupObj = CancelableCleanup(@makeValueTrue);
            
            value = false;
            cleanupObj.cancelAndInvoke();
            testCase.verifyTrue(value);
            testCase.verifyTrue(cleanupObj.Cancelled);
            
            value = false;
            delete(cleanupObj);
            testCase.verifyFalse(value);
        end
    end
end

function dummySubFunc()
end

% "imports" ---------------------------------------------------------------
function cleanupObj = CancelableCleanup(varargin)
cleanupObj = matlab.unittest.internal.CancelableCleanup(varargin{:});
end

% LocalWords:  Cancelable Func func
