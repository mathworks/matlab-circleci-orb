classdef (TestTags = {''''}) ClassWithNonAlphaNumericTestTags < matlab.unittest.TestCase
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods (Test, TestTags = {'*foo*'})
        function test1(~)
        end
    end
    
    methods (Test, TestTags = {'bar$'})
        function test2(~)
        end
    end
    
    methods (Test, TestTags = {'^'})
        function test3(~)
        end
    end
    
    methods (Test, TestTags = {'$'})
        function test4(~)
        end
    end
    
    methods (Test, TestTags = {'foo*'})
        function test5(~)
        end
    end
    
    methods (Test, TestTags = {'<>'})
        function test6(~)
        end
    end
    
    methods (Test, TestTags = {'>'})
        function test7(~)
        end
    end
    
    methods (Test, TestTags = {'</a>'})
        function test8(~)
        end
    end
    
    methods (Test, TestTags = {'.*'})
        function test9(~)
        end
    end
    
    methods (Test, TestTags = {'*'})
        function test10(~)
        end
    end
    
    methods (Test, TestTags = {'<a href'})
        function test11(~)
        end
    end
    
    methods (Test, TestTags = {'<a href></a>'})
        function test12(~)
        end
    end    
end