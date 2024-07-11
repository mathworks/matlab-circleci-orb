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