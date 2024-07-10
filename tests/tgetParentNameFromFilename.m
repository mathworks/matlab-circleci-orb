classdef tgetParentNameFromFilename < matlab.unittest.TestCase
    
    % Copyright 2014-2020 The MathWorks, Inc.
    
    properties (TestParameter)
        fileNamesParams = {fullfile('folder','+pack','tfoo.m'),...
            fullfile('folder1','+pack1','+pack2','folder2','tfoo.m'),...
            fullfile('folder','+pack','tfoo.m'),...
            fullfile('folder1','+pack1','+pack2','folder2','+pack3','+pack4','folder3','tfoo.m'),...
            fullfile('folder1','+pack1','+pack2','folder2','+pack3','+pack4','+pack5','tfoo.m'),...
            fullfile('+pack','tfoo.m'),...
            fullfile('@class1','tfoo.m'),...
            fullfile('folder1','folder2','tfoo.m'),...
            fullfile('folder1','@class2','tfoo.m'),...
            fullfile('+pack','@class3','tfoo.m'),...
            fullfile('+pack','folder1','@class4','tfoo.m'),...
            fullfile('@class5','class5.m')};
        
        expectedParentNames = {"pack.tfoo", "tfoo", "pack.tfoo" ,"tfoo", "pack3.pack4.pack5.tfoo", ...
            "pack.tfoo", "class1", "tfoo", "class2", "pack.class3", "class4", "class5"};
    end
    
    methods (Test, ParameterCombination='sequential')
        function simpleFile(testCase)
            filename = fullfile('some', 'folder', 'somefile.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("somefile"));
        end
        
        function fileInPackage(testCase)
            filename = fullfile('folder', '+some', '+package', 'somefile.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("some.package.somefile"));
        end
        
        function firstFolderIsPackage(testCase)
            filename = fullfile('+package', 'somefile.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.somefile"));
        end
        
        function classFileInClassFolder(testCase)
            filename = fullfile('folder','@foo', 'foo.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("foo"));
            
            % check for contents of a class folder within a package
            filename = fullfile('folder', '+package', '@foo', 'foo.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.foo"));
        end
        
        function methodFileInClassFolder(testCase)
            filename = fullfile('folder','@foo', 'somefile.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("foo"));
            
            % check for contents of a class folder within a package
            filename = fullfile('folder', '+package', '@foo', 'somefile.m');
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.foo"));
        end
        
        %string version
        function fileInPackageString(testCase)
            filename = fullfile("folder", "+some", "+package", "somefile.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("some.package.somefile"));
        end
        
        function firstFolderIsPackageString(testCase)
            filename = fullfile("+package", "somefile.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.somefile"));
        end
        
        function classFileInClassFolderString(testCase)
            filename = fullfile("folder", "@foo", "foo.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("foo"));
            
            % check for contents of a class folder within a package
            filename = fullfile("folder", "+package", "@foo", "foo.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.foo"));
        end
        
        function methodFileInClassFolderString(testCase)
            filename = fullfile("folder", "@foo", "somefile.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("foo"));
            
            % check for contents of a class folder within a package
            filename = fullfile("folder", "+package", "@foo", "somefile.m");
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo("package.foo"));
        end
        
        
        %Getting all combos for the LCM issue g2011486%
        function checkForParentNameOnEdgeCases(testCase, fileNamesParams, expectedParentNames)
            parentName = getParentNameFromFilename(char(fileNamesParams));
            testCase.verifyThat(parentName, IsEqualTo(expectedParentNames));
        end
        
        function vectorizedInputs(testCase)
            filename1 = fullfile('some', 'folder', 'somefile.m');
            filename2 = fullfile('folder', '@foo', 'somefile.m');
            filename3 = fullfile('folder', '+package', '@foo', 'foo.m');
            filename4 = fullfile('some', '+pack', 'somefile.m');
            files = {filename1, filename2; filename3, filename4};
            
            parentNames = getParentNameFromFilename(files);
            
            testCase.verifyThat(parentNames, IsEqualTo(["somefile", "foo"; "package.foo", "pack.somefile"]));
        end
        
        function emptyStringInput(testCase)
            filename = string.empty(1,0);
            parentName = getParentNameFromFilename(filename);
            testCase.verifyThat(parentName, IsEqualTo(filename));
        end
    end
end

% "Imports"
function p = getParentNameFromFilename(f)
p = matlab.unittest.internal.getParentNameFromFilename(f);
end
function c = IsEqualTo(varargin)
c = matlab.unittest.constraints.IsEqualTo(varargin{:});
end

% LocalWords:  somefile tfoo
