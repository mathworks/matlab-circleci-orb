classdef tWarningStackPrinter < matlab.unittest.TestCase
    
    % Copyright 2017-2020 The MathWorks, Inc.
    
    properties (TestParameter)
        HotLinks = {false, true}
        TestEnv = {'','1'}
    end
    
    methods (TestClassSetup)
        function warningBacktraceON(testCase)
            backtrace = warning('query', 'backtrace');
            testCase.addTeardown(@warning, backtrace);
            
            warning('backtrace','on');
        end
    end
    
    
    methods (Test)
        
        function meta(testCase)
            
            cls = ?matlab.unittest.internal.WarningStackPrinter;
            testCase.assertThat(cls, ~IsEmpty);
            
            testCase.verifyThat(cls <= ?handle, IsTrue);
            
            testCase.verifyThat(findobj(cls.MethodList, 'Name', 'enable'), ~IsEmpty);
            testCase.verifyThat(findobj(cls.MethodList, 'Name', 'disable'), ~IsEmpty);
        end
        
        function test_Constructor(testCase)
            
            WarningStackPrinter; % happy path
            
            testCase.verifyThat(@()WarningStackPrinter(1), Throws('MATLAB:TooManyInputs'));
            testCase.verifyThat(@()WarningStackPrinter('too many'), Throws('MATLAB:TooManyInputs'));
        end
        
        function test_display(testCase)
            printer = WarningStackPrinter;
            printer.enable;
            
            testCase.forgiveWarnings();
            
            msg = 'Intentionally issued warning';
            content = evalc('warning(''dummy:expected:warning'',msg)');
            
            lines = strsplit(content, newline);
            testCase.assertThat(lines, HasElementCount(3));
            testCase.verifyThat(lines{1}, ContainsSubstring(msg));
            testCase.verifyThat(lines{2}, ContainsSubstring('tWarningStackPrinter/test_display'), 'Should use the correct top line');
            testCase.verifyThat(lines{3}, IsEmpty);
        end
        
        function test_disableInstance(testCase)
            % Can't verify that the stack printing was completely disabled
            % since the TestRunner always has one enabled. But we can
            % sanity-check that the global resource was not disabled and
            % the stacks are still trimmed.
            printer = WarningStackPrinter;
            printer.enable;
            printer.disable;
            
            testCase.forgiveWarnings();
            
            content = evalc('warning(''dummy:expected:warning'',''dummy message'')');
            
            lines = strsplit(content, newline);
            testCase.verifyThat(lines, HasElementCount(3));
        end
        
        function test_RespectsWarningOff(testCase)
            
            % turn this warning "off"
            id = 'dummy:suppressed:warning';
            testCase.applyFixture(SuppressedWarningsFixture(id));
            
            printer = WarningStackPrinter;
            printer.enable;
            
            out = evalc('warning(id,''Issue suppressed warning'')');
            
            testCase.verifyThat(out, IsEmpty);
        end
        
        function test_RespectsBacktraceOff(testCase)
            
            backtrace = warning('query', 'backtrace');
            testCase.addTeardown(@warning, backtrace);
            
            warning('backtrace','off');
            
            printer = WarningStackPrinter;
            printer.enable;
            
            testCase.forgiveWarnings();
            output = evalc('addStackFrames(10, @()warning(''dummy:id'', ''dummy message''))');
            
            lines = strsplit(output, newline);
            testCase.assertThat(lines, HasElementCount(2));
            testCase.verifyThat(lines{1}, ContainsSubstring('dummy message'));
            testCase.verifyThat(lines{2}, IsEmpty);
        end
        
        function test_RespectsSuppressCommandLineOutput(testCase)
            
            orig = feature('SuppressCommandLineOutput', 1);
            testCase.addTeardown(@()feature('SuppressCommandLineOutput', orig));
            
            printer = WarningStackPrinter;
            printer.enable;
            
            testCase.forgiveWarnings();
            output = evalc('addStackFrames(10, @()warning(''dummy:id'', ''dummy message''))');
            
            testCase.verifyThat(output, IsEmpty);
        end
        
        function test_RespectsHotlinks(testCase, HotLinks, TestEnv)
            import matlab.unittest.internal.fevalcRespectingHotlinks;
            import matlab.unittest.internal.richFormattingSupported;
            
            testCase.setHotlinks(HotLinks);
            testCase.setTestEnv(TestEnv);
            
            printer = WarningStackPrinter;
            printer.enable;
            
            testCase.forgiveWarnings();
            
            output = fevalcRespectingHotlinks(@()warning('dummy:id', 'dummy message'));
            
            testCase.verifyThat(contains(output, '<a href='), IsEqualTo(richFormattingSupported), output);
        end
        
        % function test_SanityCheckForLXEOptimizedBuiltins(testCase)
        %     % A category of low-level builtins are marked to not call back
        %     % into MATLAB, and can leverage "deferred" warnings
        % 
        %     printer = WarningStackPrinter;
        %     printer.enable;
        % 
        %     testCase.forgiveWarnings();
        % 
        %     testCase.assertThat(@()int8(1):int8([]), IssuesWarnings("MATLAB:colon:operandsNotRealScalar"));
        % 
        %     testCase.assumeFail('Waiting on g1616821');
        %     output = evalc('int8(1):int8([]);');
        % 
        %     lines = strsplit(output, newline);
        %     testCase.assertThat(lines, HasElementCount(3));
        %     % one stack, one message (in any order), and a trailing newline
        %     testCase.verifyThat(lines{1}, ~IsEmpty);
        %     testCase.verifyThat(lines{2}, ~IsEmpty);
        %     testCase.verifyThat(lines{3}, IsEmpty);
        % end
        
        function deletedPrinter(~)
            % g1745325: MATLAB should not crash when calling methods on a
            % deleted WarningStackPrinter instance.
            
            p = WarningStackPrinter;
            delete(p);
            p.enable;
            p.disable;
        end
    end

    methods (Access = private)
        
        function forgiveWarnings(testCase)
            % This test may itself be run with a FailOnWarningsPlugin. Notify that
            % "outer" plugin of the expected warnings issued by this test to prevent
            % failures. While warnings and ExpectedWarningsNotifier are global, each
            % plugin is scoped.
            
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            import matlab.unittest.internal.constraints.WarningLogger;
            
            logger = WarningLogger;
            logger.start();
            testCase.addTeardown(@()ExpectedWarningsNotifier.notifyExpectedWarnings(logger.Warnings));
        end
        
        function setTestEnv(testCase, value)
            env = 'MATLAB_UNATTENDED_TEST_ENVIRONMENT';
            orig = getenv(env);
            testCase.addTeardown(@()setenv(env,orig));
            setenv(env, value);
        end
        
        function setHotlinks(testCase, value)
            orig = feature('hotlinks');
            testCase.addTeardown(@()feature('hotlinks',orig));
            feature('hotlinks',value)
        end
        
    end
    
end

function addStackFrames(n, fun)
if n>0
    addStackFrames(n-1, fun)
else
    fun();
end
end

function p = WarningStackPrinter(varargin)
p = matlab.unittest.internal.WarningStackPrinter(varargin{:});
end

function c = ContainsSubstring(varargin)
c = matlab.unittest.constraints.ContainsSubstring(varargin{:});
end
function c = HasElementCount(varargin)
c = matlab.unittest.constraints.HasElementCount(varargin{:});
end
function c = IsEmpty(varargin)
c = matlab.unittest.constraints.IsEmpty(varargin{:});
end
function c = IsEqualTo(varargin)
c = matlab.unittest.constraints.IsEqualTo(varargin{:});
end
function c = IssuesWarnings(varargin)
c = matlab.unittest.constraints.IssuesWarnings(varargin{:});
end
function c = IsTrue(varargin)
c = matlab.unittest.constraints.IsTrue(varargin{:});
end
function f = SuppressedWarningsFixture(varargin)
f = matlab.unittest.fixtures.SuppressedWarningsFixture(varargin{:});
end
function c = Throws(varargin)
c = matlab.unittest.constraints.Throws(varargin{:});
end

% LocalWords:  unittest Env Teardown cls strsplit fevalc LXE Builtins builtins
% LocalWords:  env
