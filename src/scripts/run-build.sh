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
    local status=0

    if command -v wget >/dev/null 2>&1; then
        wget --retry-connrefused --waitretry=5 -qO- "$url" || status=$?
    elif command -v curl >/dev/null 2>&1; then
        curl --retry 5 --retry-connrefused --retry-delay 5 -sSL "$url" || status=$?
    else
        echo "Could not find wget or curl command" >&2
        return 1
    fi

    if [ $status -ne 0 ]; then
        echo "Error streaming file from $url" >&2
    fi

    return $status
}

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-build')

# install run-matlab-command
stream https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v2/install.sh | sudoIfAvailable -s -- "${tmpdir}/bin"

# form OS appropriate paths for MATLAB
os=$(uname)
scriptdir="$tmpdir"
binext=""
if [[ "$os" = CYGWIN* || "$os" = MINGW* || "$os" = MSYS* ]]; then
    scriptdir=$(cygpath -w "$scriptdir")
    binext=".exe"
fi

# create buildtool command from parameters
buildCommand="buildtool"

if [ -n "$PARAM_TASKS" ]; then
    buildCommand+=" ${PARAM_TASKS}"
fi
if [ -n "$PARAM_BUILD_OPTIONS" ]; then
    buildCommand+=" ${PARAM_BUILD_OPTIONS}"
fi

# create script to execute
script="command_${RANDOM}"
scriptpath="${tmpdir}/${script}.m"
echo "cd(getenv('MW_ORIG_WORKING_FOLDER'));" > "$scriptpath"
cat << EOF >> "$scriptpath"
$buildCommand
EOF

# run MATLAB command
"${tmpdir}/bin/run-matlab-command$binext" "setenv('MW_ORIG_WORKING_FOLDER', cd('${scriptdir//\'/\'\'}'));$script" $PARAM_STARTUP_OPTIONS