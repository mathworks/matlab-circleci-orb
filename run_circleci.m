function stdout = run_circleci(paramSplitType, paramSelectByTag, paramSelectByFolder, paramSourceFolder)

    import matlab.unittest.selectors.HasTag;
    import matlab.unittest.constraints.StartsWithSubstring;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.selectors.HasBaseFolder;

    if ~isempty(paramSourceFolder)
        dirs = strtrim(strsplit(paramSourceFolder, {';', ':'}));
        for i = numel(dirs):-1:1
            code{i} = sprintf('addpath(genpath(''%s''));', strrep(dirs{i}, '''', ''''''));
            eval(code{i});
        end
    end    

    suite = testsuite(pwd, 'IncludingSubfolders', true);

    if ~isempty(paramSelectByTag)
        dynamicStatement = sprintf('suite = suite.selectIf(HasTag(''%s''));', paramSelectByTag);
        eval(dynamicStatement);
    end     

    if ~isempty(paramSelectByFolder)
        text = sample_script(paramSelectByFolder);
        eval(text);
    end  

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

    testNames= unique(testFilePaths);

    if strcmp(paramSplitType, 'timings')
        [~, testNames, ~] = cellfun(@fileparts, testNames, 'UniformOutput', false);
    end
    tempAllFile = tempname;
    tempErrorFile = tempname;
    fid = fopen(tempAllFile, 'w');
    fprintf(fid, '%s\n', testNames{:});
    fclose(fid);

    command = sprintf('circleci tests split --split-by=%s %s 2> %s', paramSplitType, tempAllFile, tempErrorFile);
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