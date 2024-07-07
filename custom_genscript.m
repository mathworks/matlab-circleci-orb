function scriptText = custom_genscript(varargin)
    %GENSCRIPT Generate a MATLAB script for running tests.
    scriptText = join([ ...
        "import matlab.unittest.TestRunner;", ...
        "import matlab.unittest.plugins.XMLPlugin;", ...
        "import matlab.unittest.plugins.TestReportPlugin;", ...
        newline, ...
        "suite = testsuite(pwd, 'IncludingSubfolders', true);", ...
        "testFiles = unique({suite.TestParentName});", ...
        "[~,~] = mkdir('tests');", ...
        "tempAllFile = tempname;", ...
        "tempSplitFile = tempname;", ...
        "fid = fopen(tempAllFile, 'w');", ...
        "fprintf(fid, '%s\n', testFiles{:});", ...
        "fclose(fid);", ...
        "command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempAllFile, tempSplitFile);", ...
        "[status, stdout] = system(command);", ...
        "suite = testsuite_generation(stdout, tempSplitFile);", ...
        "delete(tempAllFile);", ...
        "delete(tempSplitFile);", ...
        newline, ...
        "runner = TestRunner.withTextOutput();", ...
        "runner.addPlugin(TestReportPlugin.producingPDF('tests/results.pdf'));", ...
        "runner.addPlugin(XMLPlugin.producingJUnitFormat('tests/results.xml'));", ...
        newline, ...
        "results = runner.run(suite);", ...
        "display(results);", ...
        newline, ...
        "assertSuccess(results);" ...
    ], newline);

    % Convert to character array 
    scriptText = char(scriptText);
end