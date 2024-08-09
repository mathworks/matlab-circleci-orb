function stdout = run_circleci(splitBy)
    suite = testsuite('tests', 'IncludingSubfolders', true);
    testFilePaths = {};
    
    for i = 1:numel(suite)
        baseFolder = suite(i).BaseFolder;
        testClass = suite(i).TestParentName;
    
        if isstring(testClass)
            testClass = char(testClass);
        end
    
        testFilePath = fullfile(baseFolder, strcat(testClass, '.m'));
        testFilePaths{end+1} = testFilePath; 
    end

    uniqueTestFilePaths = unique(testFilePaths);
    [~, testNames, ~] = cellfun(@fileparts, uniqueTestFilePaths, 'UniformOutput', false);
    tempAllFile = tempname;
    tempErrorFile = tempname;
    fid = fopen(tempAllFile, 'w');
    fprintf(fid, '%s\n', testNames{:});
    fclose(fid);
    command = sprintf('circleci tests split --split-by=%s %s 2> %s', splitBy, tempAllFile, tempErrorFile);
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