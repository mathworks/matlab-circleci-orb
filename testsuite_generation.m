function suite = testsuite_generation(stdout, tempFile)

    import matlab.unittest.TestSuite;
    stderr = fileread(tempFile);
    disp(stderr);
    
    stdout = strtrim(strsplit(stdout, '\n'));
    stdout = stdout(~cellfun('isempty', stdout));
    
    suites = {};
    cd tests
    for i = 1:length(stdout)
    testFilePath = fullfile('.', [stdout{i}, '.m']);
    suites{end+1} = TestSuite.fromFile(testFilePath);
    end
    suite = [suites{:}];
end