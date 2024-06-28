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

tempFile = tempname; 
command = 'circleci tests split --split-by=timings tempFile1 2>' + string(tempFile);

[status, stdout] = system(command);
stderr = fileread(tempFile);
disp('Standard Error (stderr):');
disp(stderr);
delete(tempFile);
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