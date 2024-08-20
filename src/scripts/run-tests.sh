#!/bin/bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

sudoIfAvailable() {
    if command -v sudo >/dev/null 2>&1; then
        sudo -E bash "$@"
    else
        bash "$@"
    fi
}

stream() {
    local url="$1"
    if command -v wget >/dev/null 2>&1; then
        wget --retry-connrefused --waitretry=5 -qO- "$url"
    elif command -v curl >/dev/null 2>&1; then
        curl --retry 5 --retry-connrefused --retry-delay 5 -sSL "$url"
    else
        echo "Could not find wget or curl command" >&2
        return 1
    fi
}

download() {
    local url="$1"
    local filename="$2"
    if command -v wget >/dev/null 2>&1; then
        wget --retry-connrefused --waitretry=5 -qO "$filename" "$url" 2>&1
    elif command -v curl >/dev/null 2>&1; then
        curl --retry 5 --retry-connrefused --retry-delay 5 -sSLo "$filename" "$url"
    else
        echo "Could not find wget or curl command" >&2
        return 1
    fi
}

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-tests')

# install run-matlab-command
stream https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v2/install.sh | sudoIfAvailable -s -- "${tmpdir}/bin"

# download script generator
download https://ssd.mathworks.com/supportfiles/ci/matlab-script-generator/v0/matlab-script-generator.zip "${tmpdir}/scriptgen.zip"
unzip -qod "${tmpdir}/scriptgen" "${tmpdir}/scriptgen.zip"

# form OS appropriate paths for MATLAB
os=$(uname)
gendir="$tmpdir"
binext=""
if [[ "$os" = CYGWIN* || "$os" = MINGW* || "$os" = MSYS* ]]; then
    gendir=$(cygpath -w "$gendir")
    binext=".exe"
fi

echo "Command to be executed: $PARAM_SELECT_BY_NAME"
TESTFILES=$(eval echo "$PARAM_SELECT_BY_NAME")
circleciTestFiles="{${TESTFILES}}"
echo "TESTFILES ARE: $circleciTestFiles"

"${tmpdir}/bin/run-matlab-command$binext" "\
    testScript = genscript('Test',\
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
    'UseParallel',${PARAM_USE_PARALLEL},\
    'CircleCITestFiles', $circleciTestFiles,\
    'OutputDetail','${PARAM_OUTPUT_DETAIL}',\
    'LoggingLevel','${PARAM_LOGGING_LEVEL}');\
    disp('Running MATLAB script with contents:');\
    disp(testScript.Contents);\
    fprintf('__________\n\n');\
    run(testScript);" $PARAM_STARTUP_OPTIONS