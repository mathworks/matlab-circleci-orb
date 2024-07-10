function scriptText = my_genscript(varargin)
    %GENSCRIPT Generate a MATLAB script for running tests.
    scriptText = join([ ...
        "import matlab.unittest.TestRunner;", ...
        "import matlab.unittest.plugins.XMLPlugin;", ...
        "import matlab.unittest.plugins.TestReportPlugin;", ...
        newline, ...
        "suite = testsuite('tests', 'IncludingSubfolders', true);", ...
        "testFiles = unique({suite.TestParentName});", ...
        "tempAllFile = tempname;", ...
        "tempErrorFile = tempname;", ...
        "fid = fopen(tempAllFile, 'w');", ...
        "fprintf(fid, '%s\n', testFiles{:});", ...
        "fclose(fid);", ...
        "command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempAllFile, tempErrorFile);", ...
        "[status, stdout] = system(command);", ...
        "suite = testsuite_generation(stdout, tempErrorFile, suite);", ...
        "delete(tempAllFile);", ...
        "delete(tempErrorFile);", ...
        newline, ...
        "runner = TestRunner.withTextOutput();", ...
        "runner.addPlugin(TestReportPlugin.producingPDF('results.pdf'));", ...
        "runner.addPlugin(XMLPlugin.producingJUnitFormat('results.xml'));", ...
        newline, ...
        "results = runner.run(suite);", ...
        "display(results);", ...
        newline, ...
        "assertSuccess(results);" ...
    ], newline);

    % Convert to character array 
    scriptText = char(scriptText);
end