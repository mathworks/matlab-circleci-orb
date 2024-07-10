function scriptText = custom_genscript(varargin)
    %GENSCRIPT Generate a MATLAB script for running tests.
    TestFiles= varargin{35};
    scriptText = join([ ...
        "import matlab.unittest.TestRunner;", ...
        "import matlab.unittest.plugins.XMLPlugin;", ...
        newline, ...
        "suite = testsuite('tests', 'IncludingSubfolders', true);", ...
        "patterns = strcat(TestFiles, '/*');", ...
        "suite = selectIf(suite, 'Name', patterns);", ...
        newline, ...
        "runner = TestRunner.withTextOutput();", ...
        "runner.addPlugin(XMLPlugin.producingJUnitFormat('results.xml'));", ...
        newline, ...
        "results = runner.run(suite);", ...
        "display(results);", ...
        newline, ...
        "assertSuccess(results);" ...
    ], newline);

    % Convert to character array 
    scriptText = char(scriptText);
    disp('Running MATLAB script with contents:');
    disp('__________');
    disp(scriptText);
    disp('__________');

    eval(scriptText);
end 