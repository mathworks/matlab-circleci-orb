classdef HasUnsealedTestTags < matlab.unittest.TestCase
    % Test double
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (Test, TestTags = {'Unsealed'})
        function test1(~)
        end
    end    
end