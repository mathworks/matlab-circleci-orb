classdef HasSealedTestTags < matlab.unittest.TestCase
    % Test double
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (Sealed, Test, TestTags = {'Sealed'})
        function test1(~)
        end
    end    
end