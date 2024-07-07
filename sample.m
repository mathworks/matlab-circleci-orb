import matlab.unittest.TestRunner;
import matlab.unittest.plugins.XMLPlugin;
import matlab.unittest.plugins.TestReportPlugin;

suite = testsuite(pwd, 'IncludingSubfolders', true);
testFiles = unique({suite.TestParentName});
[~,~] = mkdir('tests');
tempAllFile = tempname;
tempSplitFile = tempname;
fid = fopen(tempAllFile, 'w');
fprintf(fid, '%s\n', testFiles{:});
fclose(fid);
command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempAllFile, tempSplitFile); 
[status, stdout] = system(command);
suite = testsuite_generation(stdout, tempSplitFile);
delete(tempAllFile);
delete(tempSplitFile);

runner = TestRunner.withTextOutput();
runner.addPlugin(TestReportPlugin.producingPDF('tests/results.pdf'));
runner.addPlugin(XMLPlugin.producingJUnitFormat('tests/results.xml'));

results = runner.run(suite);
display(results);


assertSuccess(results);