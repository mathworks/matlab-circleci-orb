function scriptText = custom_genscript(varargin)
    %GENSCRIPT Generate a MATLAB script for running tests.
    scriptText = join([ ...
        "import matlab.unittest.TestRunner;", ...
        "import matlab.unittest.plugins.XMLPlugin;", ...
        "testFiles = testsuite(pwd, 'IncludingSubfolders', true);", ...
        "uniqueTestParentNames = unique({testFiles.TestParentName});", ...
        "tempFile1 = tempname;", ...
        "fid = fopen(tempFile1, 'w');", ...
        "fprintf(fid, '%s\n', uniqueTestParentNames{:});", ...
        "fclose(fid);", ...
        "tempFile2 = tempname;", ...
        "command = 'sprintf('circleci tests split --split-by=timings %s 2> %s', tempFile1, tempFile2);", ...
        "[status, stdout] = system(command);", ...
        "suite = testsuite_generation(stdout, tempFile2);", ...
        "delete(tempFile1);", ...
        "delete(tempFile2);", ...
        "runner = TestRunner.withTextOutput();", ...
        "runner.addPlugin(XMLPlugin.producingJUnitFormat('results.xml'));", ...
        "results = runner.run(suite);", ...
        "display(results);", ...
        "assertSuccess(results);" ...
    ], newline);

    % Convert to character array 
    scriptText = char(scriptText);
end