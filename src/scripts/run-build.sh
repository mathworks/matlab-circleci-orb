downloadAndRun() {
    url=$1
    shift
    if [[ -x $(command -v sudo) ]]; then
    curl -sfL $url | sudo -E bash -s -- "$@"
    else
    curl -sfL $url | bash -s -- "$@"
    fi
}

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-command')

# install run-matlab-command
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v2/install.sh "${tmpdir}/bin"

# form OS appropriate paths for MATLAB
os=$(uname)
scriptdir=$tmpdir
binext=""
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
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
script=command_${RANDOM}
scriptpath=${tmpdir}/${script}.m
echo "cd(getenv('MW_ORIG_WORKING_FOLDER'));" > "$scriptpath"
cat << EOF >> "$scriptpath"
$buildCommand
EOF

# run MATLAB command
"${tmpdir}/bin/run-matlab-command$binext" "setenv('MW_ORIG_WORKING_FOLDER', cd('${scriptdir//\'/\'\'}'));$script" $PARAM_STARTUP_OPTIONS
