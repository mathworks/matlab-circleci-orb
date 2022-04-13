downloadAndRun() {
    url=$1
    shift
    if [[ -x $(command -v sudo) ]]; then
    curl -sfL $url | sudo -E bash -s -- "$@"
    else
    curl -sfL $url | bash -s -- "$@"
    fi
}

os=$(uname)

# installer does not support the Docker executor type on Linux
if [[ $os = Linux ]] && awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
    echo 'The Docker executor type is not supported.'
    exit 1
fi

# install core system dependencies
if [[ $os = Linux ]]; then
    downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-deps/v0/install.sh ${PARAM_RELEASE}
fi

# install ephemeral version of MATLAB
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/ephemeral-matlab/v0/ci-install.sh --release ${PARAM_RELEASE}

# add MATLAB to path
tmpdir=$(dirname "$(mktemp -u)")
rootdir=$(cat "$tmpdir/ephemeral_matlab_root")
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    rootdir=$(cygpath "$rootdir")
fi
echo 'export PATH="'$rootdir'/bin:$PATH"' >> $BASH_ENV
