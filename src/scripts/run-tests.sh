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


"${tmpdir}/bin/run-matlab-command$binext" "\
    sample;" $PARAM_STARTUP_OPTIONS
