function stdout = getCircleCISplitFiles(paramSplitType, paramSelectByTag, paramSelectByFolder, paramSourceFolder)
% getCircleCISplitFiles - splits test files using CircleCI split command.
%
%   The getCircleCISplitFiles function provides a convenient way to
%   split test files based on specified parameters.
%
%   STDOUT = getCircleCISplitFiles(PARAMSPLITTYPE, PARAMSELECTBYTAG, 
%   PARAMSELECTBYFOLDER, PARAMSOURCEFOLDER) generates and returns a list of 
%   split test files. The parameters are as follows:
%       - PARAMSPLITTYPE: The type of split (e.g., 'timings', 'filename' or 'filesize').
%       - PARAMSELECTBYTAG: A tag to filter tests by.
%       - PARAMSELECTBYFOLDER: folder(s) to filter tests by.
%       - PARAMSOURCEFOLDER: The source folder(s) to add to the path.
%
%   These parameters are used to update the test suite and extract the list 
%   of MATLAB test files to be passed to the CircleCI test split command.
%
%   Examples:
%
%       resultFiles = getCircleCISplitFiles('timings', 'MyTag', 'MyFolder', 'src');
%       disp(resultFiles);
  

    import matlab.unittest.selectors.HasTag;
    import matlab.unittest.constraints.StartsWithSubstring;
    import matlab.unittest.plugins.XMLPlugin;
    import matlab.unittest.selectors.HasBaseFolder;

    if ~isempty(paramSourceFolder)
        dirs = strtrim(strsplit(paramSourceFolder, {';', ':'}));
        for i = numel(dirs):-1:1
            statement{i} = sprintf('addpath(genpath(''%s''));', strrep(dirs{i}, '''', ''''''));
            eval(statement{i});
        end
    end    

    suite = testsuite(pwd, 'IncludingSubfolders', true);

    if ~isempty(paramSelectByTag)
        Statement = sprintf('suite = suite.selectIf(HasTag(''%s''));', paramSelectByTag);
        eval(Statement);
    end     

    if ~isempty(paramSelectByFolder)
        Statement =  generateFolderSelectionStatement(paramSelectByFolder);
        eval(Statement);
    end  

    testFilePaths = {};

    for i = 1:numel(suite)
        baseFolder = suite(i).BaseFolder;
        relativePath = strrep(baseFolder, [pwd, filesep], '');
        testClass = suite(i).TestParentName;
    
        if isstring(testClass)
            testClass = char(testClass);
        end
    
        testFilePath = fullfile(relativePath, strcat(testClass, '.m'));
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

    if strcmp(paramSplitType, 'filename')
        command = sprintf('circleci tests split %s 2> %s', tempAllFile, tempErrorFile);
    else
        command = sprintf('circleci tests split --split-by=%s %s 2> %s', paramSplitType, tempAllFile, tempErrorFile);
    end
    [~, stdout] = system(command);

    stderr = fileread(tempErrorFile);
    disp(stderr);

    
    stdout = strsplit(stdout, '\n');
    stdout = stdout(~cellfun('isempty', stdout)); 
    stdout = strtrim(stdout);
    stdout = stdout(:)';
    [~, stdout, ~] = cellfun(@fileparts, stdout, 'UniformOutput', false);

    delete(tempAllFile);
    delete(tempErrorFile);
end