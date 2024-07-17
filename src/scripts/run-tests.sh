downloadAndRun() {
    url=$1
    shift
    if [[ -x $(command -v sudo) ]]; then
    curl -sfL $url | sudo -E bash -s -- "$@"
    else
    curl -sfL $url | bash -s -- "$@"
    fi
}

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-tests')

# install run-matlab-command
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v2/install.sh "${tmpdir}/bin"

# download script generator
curl -sfLo "${tmpdir}/scriptgen.zip" https://ssd.mathworks.com/supportfiles/ci/matlab-script-generator/v0/matlab-script-generator.zip
unzip -qod "${tmpdir}/scriptgen" "${tmpdir}/scriptgen.zip"

# form OS appropriate paths for MATLAB
os=$(uname)
gendir=$tmpdir
binext=""
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    gendir=$(cygpath -w "$gendir")
    binext=".exe"
fi
echo "Command to be executed: $PARAM_SELECT_BY_FILES"
TESTFILES=$(eval "$PARAM_SELECT_BY_FILES")
TEMP_TESTFILES=$(eval "$PARAM_SELECT_BY_FILES")

# Print the output to verify it
echo "Output of the command:"
echo "$TEMP_TESTFILES"

"${tmpdir}/bin/run-matlab-command$binext" "\
    testScript = custom_genscript('Test',\
    'JUnitTestResults','${PARAM_TEST_RESULTS_JUNIT}',\
    'CoberturaCodeCoverage','${PARAM_CODE_COVERAGE_COBERTURA}',\
    'HTMLCodeCoverage','${PARAM_CODE_COVERAGE_HTML}',\
    'SourceFolder','${PARAM_SOURCE_FOLDER}',\
    'SelectByFolder','${PARAM_SELECT_BY_FOLDER}',\
    'SelectByTag','$PARAM_SELECT_BY_TAG',\
    'CoberturaModelCoverage','${PARAM_MODEL_COVERAGE_COBERTURA}',\
    'HTMLModelCoverage','${PARAM_MODEL_COVERAGE_HTML}',\
    'SimulinkTestResults','${PARAM_TEST_RESULTS_SIMULINK_TEST}',\
    'HTMLTestReport','${PARAM_TEST_RESULTS_HTML}',\
    'PDFTestReport','${PARAM_TEST_RESULTS_PDF}',\
    'Strict',${PARAM_STRICT},\
    'SplitType', '${PARAM_SPLIT_TYPE}',\
    'UseParallel',${PARAM_USE_PARALLEL},\
    'OutputDetail','${PARAM_OUTPUT_DETAIL}',\
    'LoggingLevel','${PARAM_LOGGING_LEVEL}');" $PARAM_STARTUP_OPTIONS
     