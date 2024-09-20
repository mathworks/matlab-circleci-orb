classdef SuperclassHasTestMethodTestTags < matlab.unittest.TestCase
    % Test double
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (Test, TestTags = {'Original'})
        function test1(~)
        end
    end    
end