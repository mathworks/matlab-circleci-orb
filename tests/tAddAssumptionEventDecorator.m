classdef tAddAssumptionEventDecorator < matlab.unittest.TestCase
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods (TestClassSetup)
        function classExists(testCase)
            testCase.assertNotEmpty(?matlab.unittest.internal.AddAssumptionEventDecorator,...
                'Could not find the Task interface');
        end
    end
    
    methods (Test)
        
        function checkSuperclass(testCase)
            parentClass = superclasses('matlab.unittest.internal.AddAssumptionEventDecorator');
            
            testCase.verifyEqual(parentClass{1}, 'matlab.unittest.internal.TaskDecorator',...
                'AddAssumptionEventDecorator should be a subclass of matlab.unittest.internal.TaskDecorator');
        end
               
        function constructorWithInvalidInputs(testCase)
            import matlab.unittest.internal.AddAssumptionEventDecorator
            
            testCase.verifyError(@()AddAssumptionEventDecorator(5),'MATLAB:invalidType',...
                'AddAssumptionEventDecorator constructor should throw and exception');
            testCase.verifyError(@()AddAssumptionEventDecorator(@foo),'MATLAB:invalidType',...
                'AddAssumptionEventDecorator constructor should throw and exception');
            testCase.verifyError(@()AddAssumptionEventDecorator('test'),'MATLAB:invalidType',...
                'AddAssumptionEventDecorator constructor should throw and exception');
        end
        
        function constructorWithValidInput(testCase)
            import matlab.unittest.internal.AddAssumptionEventDecorator
            import matlab.unittest.internal.FailureTask
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic
            
            defaultTask = FailureTask(FunctionHandleDiagnostic(@foo));
            newTask = AddAssumptionEventDecorator(defaultTask);
            
            testCase.verifyClass(newTask,'matlab.unittest.internal.AddAssumptionEventDecorator',...
                'New instance of AddAssumptionEventDecorator class should be created');
            
        end
        
        function constructorWithMultipleTasks(testCase)
            import matlab.unittest.internal.AddAssumptionEventDecorator
            import matlab.unittest.internal.FailureTask
            import matlab.unittest.diagnostics.FunctionHandleDiagnostic
            import matlab.unittest.diagnostics.StringDiagnostic
            import matlab.unittest.constraints.IsEqualTo
            
            diag1 = FunctionHandleDiagnostic(@foo);
            task1 = FailureTask(diag1);
            
            diag2 = StringDiagnostic('string diagnostic');
            task2 = FailureTask(diag2);
            tasks = [task1 task2];
            
            decoratorTaskArray = AddAssumptionEventDecorator(tasks);
            
            testCase.verifyEqual(numel(decoratorTaskArray),2,...
                'The number of AddVerificationEventDecorator instances does not match the number of FailureTasks');
            
            testCase.verifyThat(decoratorTaskArray(1).getDefaultQualificationDiagnostics,...
                IsEqualTo(diag1));
            testCase.verifyEmpty(decoratorTaskArray(1).getVerificationDiagnostics);
            testCase.verifyThat(decoratorTaskArray(1).getAssumptionDiagnostics,...
                IsEqualTo(diag1));
            
            testCase.verifyThat(decoratorTaskArray(2).getDefaultQualificationDiagnostics,...
                IsEqualTo(diag2));
            testCase.verifyEmpty(decoratorTaskArray(2).getVerificationDiagnostics);
            testCase.verifyThat(decoratorTaskArray(2).getAssumptionDiagnostics,...
                IsEqualTo(diag2));
        end
    end
    
end



