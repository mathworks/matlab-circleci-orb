function suite = testsuite_generation(stdout, tempFile)
    import matlab.unittest.TestSuite;

    % Read and display standard error
    disp(fileread(tempFile));

    % Process stdout and filter out empty lines
    stdout = strtrim(strsplit(stdout, '\n'));
    stdout = stdout(~cellfun('isempty', stdout));

    suite = testsuite(stdout);
end