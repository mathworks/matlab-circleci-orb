import matlab.unittest.TestRunner;


suite = testsuite('../..', 'IncludeSubfolders', true);
suite = suite.selectIf('Name', {'SolverTest/*'});

{suite.Name}