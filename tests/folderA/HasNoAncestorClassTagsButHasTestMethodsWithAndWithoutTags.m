classdef HasNoAncestorClassTagsButHasTestMethodsWithAndWithoutTags < matlab.unittest.TestCase

    % Copyright 2014 The MathWorks, Inc.
    
    methods (Test, TestTags = {'a', 'b'})
        function test1(~)
        end
    end

    methods (Test)
        function testNoTags1(~)
        end
        function testNoTags2(~)
        end
    end
     
end