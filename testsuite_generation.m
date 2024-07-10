function selectedSuite = testsuite_generation(stdout, tempFile, suite)
    import matlab.unittest.TestSuite;
    stderr = fileread(tempFile);
    disp(stderr);

    stdout = strsplit(stdout, '\n');
    stdout = stdout(~cellfun('isempty', stdout));
    stdout = strtrim(stdout);
    stdoutCellArray = stdout(:)';

    patterns = strcat(stdoutCellArray, '/*');
    selectedSuite = selectIf(suite, "Name", patterns);
  
end