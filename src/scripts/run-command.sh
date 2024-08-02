#!/bin/bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

sudoIfAvailable() {
    local cmd="$1"
    shift
    if command -v sudo >/dev/null 2>&1; then
        sudo -E bash "$cmd" "$@"
    else
        bash "$cmd" "$@"
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

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-command')

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

# create script to execute
script="command_${RANDOM}"
scriptpath="${tmpdir}/${script}.m"
echo "cd(getenv('MW_ORIG_WORKING_FOLDER'));" > "$scriptpath"
cat << EOF >> "$scriptpath"
${PARAM_COMMAND}
EOF

# run MATLAB command
"${tmpdir}/bin/run-matlab-command$binext" "setenv('MW_ORIG_WORKING_FOLDER', cd('${scriptdir//\'/\'\'}'));$script" $PARAM_STARTUP_OPTIONS
