classdef tvalidatePathname < matlab.unittest.TestCase
    %

    % Copyright 2016-2022 The MathWorks, Inc.
    
    properties(TestParameter)
        ValidValue = struct(...
            'RelativePath',fullfile('hello','world'),...
            'FullPath',fullfile(matlabroot,'test.m'),...
            'SpaceInName','hello world');
        
        InvalidCase = createInvalidCases();
        
        InvalidWindowsCase = createInvalidWindowsCases();
    end
    
    methods(Test)
        function test_validatePathname_valid(~,ValidValue)
            matlab.unittest.internal.validatePathname(ValidValue); % should not error
        end
        
        function test_validatePathname_invalid(testCase,InvalidCase)
            testCase.verifyThat(@() matlab.unittest.internal.validatePathname(...
                InvalidCase.Pathname),Throws(InvalidCase.ErrorID));
        end
        
        function test_validatePathname_invalidWindowsOnly(testCase,InvalidWindowsCase)
            testCase.assumeReturnsTrue(@() ispc(), 'Test only applies to Windows platform');
            testCase.verifyThat(@() matlab.unittest.internal.validatePathname(...
                InvalidWindowsCase.Pathname),Throws(InvalidWindowsCase.ErrorID));
        end
    end
end


function cases = createInvalidCases()
cases.TooLongName = struct(...
	'Pathname',repmat('a',1,1000000),...
	'ErrorID','MATLAB:automation:FileIO:InvalidPathnameLength');
end

function cases = createInvalidWindowsCases()
cases.BackslashCharacter = struct(...
    'Pathname',sprintf('some \b dummy'),...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameCharacter');

cases.NewlineCharacter = struct(...
    'Pathname',sprintf('some \n dummy'),...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameCharacter');

cases.Star = struct(...
    'Pathname',sprintf('some*dummy'),...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameCharacter');

cases.Colon = struct(...
    'Pathname',fullfile(matlabroot,':','hello'),...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameCharacter');

cases.ReservedName = struct(...
    'Pathname',fullfile(matlabroot,'COM1'),...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameReserved');

cases.TrailingSpace = struct(...
    'Pathname','hello.m ',...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameTrailingSpace');

cases.TrailingDot = struct(...
    'Pathname','hello.',...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathnameTrailingDot');

cases.BadFormat = struct(...
    'Pathname','3:\hi',...
    'ErrorID','MATLAB:automation:FileIO:InvalidPathname');
end


% "imports" ---------------------------------------------------------------
function c = Throws(varargin)
c = matlab.unittest.constraints.Throws(varargin{:});
end
