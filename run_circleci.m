function stdout = run_circleci()
    suite = testsuite('tests', 'IncludingSubfolders', true);
    testFiles = unique({suite.TestParentName});
    tempAllFile = tempname;
    tempErrorFile = tempname;
    fid = fopen(tempAllFile, 'w');
    fprintf(fid, '%s\n', testFiles{:});
    fclose(fid);
    command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempAllFile, tempErrorFile);
    [~, stdout] = system(command);
    stderr = fileread(tempErrorFile);
    disp(stderr);
    stdout = strsplit(stdout, '\n');
    stdout = stdout(~cellfun('isempty', stdout));
    stdout = strtrim(stdout);
    stdout = stdout(:)';
    delete(tempAllFile);
    delete(tempErrorFile);
end