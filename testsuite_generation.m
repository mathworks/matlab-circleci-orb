function suite = testsuite_generation(stdout, tempFile)
    import matlab.unittest.TestSuite;
    stderr = fileread(tempFile);
    disp(stderr);

    stdout = strsplit(stdout, '\n');
    stdout = stdout(~cellfun('isempty', stdout));
    stdout = strtrim(stdout);
    stdoutCellArray = stdout(:)';

    suites = {};
    cd tests
    for i = 1:length(stdoutCellArray)
        testFilePath = fullfile('.', [stdoutCellArray{i}, '.m']);
        suites{end+1} = TestSuite.fromFile(testFilePath);
    end
    suite = [suites{:}];
end