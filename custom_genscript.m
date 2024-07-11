function scriptText = custom_genscript(varargin)
    %GENSCRIPT Generate a MATLAB script for running tests.
    TestFiles= varargin{35};
    disp(TestFiles);
    scriptText = join([ ...
        "import matlab.unittest.TestRunner;", ...
        "import matlab.unittest.plugins.XMLPlugin;", ...
        newline, ...
        "import matlab.unittest.TestSuite;", ...
        "suites = {};", ...
        "for i = 1:length(TestFiles)", ...
        "    suites{end+1} = TestSuite.fromFile(TestFiles{i});",...
        "end", ...
        "suite = [suites{:}];", ...
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