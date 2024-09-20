classdef ClassTestWithNotATestMethod < matlab.unittest.TestCase
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods(Test)
        function test1(~)
        end
    end
    
    methods
        function notATest(~)
        end
    end
    
end