classdef tAddVerificationEventDecorator < matlab.unittest.TestCase
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (TestClassSetup)
        function classExists(testCase)
            testCase.assertNotEmpty(?matlab.unittest.internal.AddVerificationEventDecorator,...
                'Could not find the Task interface');
        end
    end
    
    methods(Test)
        
        function checkSuperclass(testCase)
            parentClass = superclasses('matlab.unittest.internal.AddVerificationEventDecorator');
            
            testCase.verifyEqual(parentClass{1}, 'matlab.unittest.internal.TaskDecorator',...
                'AddVerificationEventDecorator should be a subclass of matlab.unittest.internal.TaskDecorator');
        end
        
        function constructorWithInvalidInputs(testCase)
            import matlab.unittest.internal.AddVerificationEventDecorator
            
            testCase.verifyError(@()AddVerificationEventDecorator(5),'MATLAB:invalidType');
            testCase.verifyError(@()AddVerificationEventDecorator(@foo),'MATLAB:invalidType');
            testCase.verifyError(@()AddVerificationEventDecorator('test'),'MATLAB:invalidType');
        end
        
        function constructorWithValidInput(testCase)
            import matlab.unittest.internal.AddVerificationEventDecorator
            import matlab.unittest.internal.FailureTask
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic
            
            defaultTask = FailureTask(FunctionHandleDiagnostic(@foo));
            newTask = AddVerificationEventDecorator(defaultTask);
            
            testCase.verifyClass(newTask,'matlab.unittest.internal.AddVerificationEventDecorator',...
                'New instance of AddVerificationEventDecorator class should be created');
            
        end
        
        function constructorWithMultipleTasks(testCase)
            import matlab.unittest.internal.AddVerificationEventDecorator
            import matlab.unittest.internal.FailureTask
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic
            import matlab.unittest.diagnostics.StringDiagnostic
            import matlab.unittest.constraints.IsEqualTo
            
            diag1 = FunctionHandleDiagnostic(@foo);
            task1 = FailureTask(diag1);
            
            diag2 = StringDiagnostic('string diagnostic');
            task2 = FailureTask(diag2);
            tasks = [task1 task2];
            
            decoratorTaskArray = AddVerificationEventDecorator(tasks);
            
            testCase.verifyEqual(numel(decoratorTaskArray),2,...
                'The number of AddVerificationEventDecorator instances does not match the number of FailureTasks');
            
            testCase.verifyThat(decoratorTaskArray(1).getDefaultQualificationDiagnostics,...
                IsEqualTo(diag1));
            testCase.verifyThat(decoratorTaskArray(1).getVerificationDiagnostics,...
                IsEqualTo(diag1));
            testCase.verifyEmpty(decoratorTaskArray(1).getAssumptionDiagnostics);
            
            testCase.verifyThat(decoratorTaskArray(2).getDefaultQualificationDiagnostics,...
                IsEqualTo(diag2));
            testCase.verifyThat(decoratorTaskArray(2).getVerificationDiagnostics,...
                IsEqualTo(diag2));
            testCase.verifyEmpty(decoratorTaskArray(2).getAssumptionDiagnostics);
        end
    end
end