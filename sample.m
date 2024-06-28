import matlab.unittest.TestRunner;
import matlab.unittest.plugins.XMLPlugin;

folderPath = pwd;
suite = testsuite(folderPath, 'IncludingSubfolders', true);

testFileNames = {};

for i = 1:numel(suite)
    testClass = suite(i).TestClass;

    if ~isempty(testClass)
        fileName = char(testClass);
    else
        testName = suite(i).Name;
        splitName = regexp(testName, '[/.]', 'split');
        fileName = char(splitName{1});
    end  
    testFileNames{end+1} = fileName; 
end
testFileNames = unique(testFileNames);

disp('Test files found:');
disp(testFileNames');

tempFile1 = tempname;
fid = fopen(tempFile1, 'w');
fprintf(fid, '%s\n', testFileNames{:});
fclose(fid);

% Step 2: Create another temporary file to capture the output
tempFile2 = tempname;

% Step 3: Construct the command string
command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempFile1, tempFile2);

[status, stdout] = system(command);
stderr = fileread(tempFile2);
disp('Standard Error (stderr):');
disp(stderr);
delete(tempFile2);
disp('Output after running circleci command:');
disp(stdout);
% suite = testsuite_generation(stdout, tempFile);
% delete(tempFile);
% 
% runner = TestRunner.withTextOutput();
% runner.addPlugin(XMLPlugin.producingJUnitFormat('results.xml'));
% results = runner.run(suite);
% display(results);
% assertSuccess(results);