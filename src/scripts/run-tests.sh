#!/bin/bash
tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-tests')

# download run command shell scripts
curl -sfLo "${tmpdir}/bin.zip" https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v0/run-matlab-command.zip
unzip -qod "${tmpdir}/bin" "${tmpdir}/bin.zip"

# download script generator
curl -sfLo "${tmpdir}/scriptgen.zip" https://ssd.mathworks.com/supportfiles/ci/matlab-script-generator/v0/matlab-script-generator.zip
unzip -qod "${tmpdir}/scriptgen" "${tmpdir}/scriptgen.zip"

# form OS appropriate paths for MATLAB
os=$(uname)
gendir=$tmpdir
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    gendir=$(cygpath -w "$gendir")
fi

# generate and run MATLAB test script
"${tmpdir}/bin/run_matlab_command.sh" "\
    addpath('${gendir}/scriptgen');\
    testScript = genscript('Test',\
    'JUnitTestResults','${PARAM_TEST_RESULTS_JUNIT}',\
    'CoberturaCodeCoverage','${PARAM_CODE_COVERAGE_COBERTURA}',\
    'HTMLCodeCoverage','${PARAM_CODE_COVERAGE_HTML}',\
    'SourceFolder','${PARAM_SOURCE_FOLDER}',\
    'SelectByFolder','${PARAM_SELECT_BY_FOLDER}',\
    'SelectByTag','$PARAM_SELECT_BY_TAG',\
    'CoberturaModelCoverage','${PARAM_MODEL_COVERAGE_COBERTURA}',\
    'SimulinkTestResults','${PARAM_TEST_RESULTS_SIMULINK_TEST}',\
    'HTMLTestReport','${PARAM_TEST_RESULTS_HTML}',\
    'PDFTestReport','${PARAM_TEST_RESULTS_PDF}');\
    disp('Running MATLAB script with contents:');\
    disp(testScript.Contents);\
    fprintf('__________\n\n');\
    run(testScript);"
