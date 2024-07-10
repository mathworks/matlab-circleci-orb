classdef tPublishableData < matlab.unittest.TestCase
    % tPublishableData - Unit tests for
    % matlab.unittest.internal.PublishableData
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods (Test)
        function objClass(testCase)
            testCh   = "foo";
            testData = 3;
            pubData  = PublishedableData(testCh, testData);
            testCase.verifyClass(pubData, 'matlab.unittest.internal.PublishableData');
        end
        
        function classProperties(testCase)
           metaClass    = ?matlab.unittest.internal.PublishableData;
           allProps     = metaClass.PropertyList;
           uniqueProps  = findobj(allProps, 'DefiningClass', metaClass);
           expPropNames = sort({'Channel', 'CustomData'});
           actPropNames = sort({uniqueProps.Name});
           testCase.assertEqual(actPropNames, expPropNames, "Class has the wrong properties declared.");
           
           expPermissions = {'immutable', 'immutable'};
           actPermissions = {uniqueProps.SetAccess};
           testCase.verifyEqual(actPermissions, expPermissions,         ...
               "Properties must have their 'SetAccess' set to 'immutable'");
        end
        
        function storedData(testCase)
           testCh   = "myID";
           testData = struct('time', 1:10, 'data', 10:-1:1);
           pubData  = PublishedableData(testCh, testData);
           testDiag = "PublishableData stored the wrong %s.";
           testCase.verifyEqual(pubData.Channel, testCh, sprintf(testDiag, "channel ID"));
           testCase.verifyEqual(pubData.CustomData, testData, sprintf(testDiag, "data"));           
        end
    end
end

%% Local Helpers ==========================================================
function pubData = PublishedableData(varargin)
pubData = matlab.unittest.internal.PublishableData(varargin{:});
end