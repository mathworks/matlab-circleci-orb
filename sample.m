t1 = testsuite(pwd, 'IncludingSubfolders', true);
uniqueTestParentNames = unique({t1.TestParentName});
tempFile1 = tempname;


fid = fopen(tempFile1, 'w');
fprintf(fid, '%s\n', uniqueTestParentNames{:});
fclose(fid);


tempFile2 = tempname;


command = sprintf('circleci tests split --split-by=timings %s 2> %s', tempFile1, tempFile2);

[status, stdout] = system(command);
stderr = fileread(tempFile2);
disp('Standard Error (stderr):');
disp(stderr);

delete(tempFile1);
delete(tempFile2);

disp('Output after running circleci command:');
disp(stdout);

