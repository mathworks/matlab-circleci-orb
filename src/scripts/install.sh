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
if [ -n "${MATHWORKS_ACCOUNT}" ] &&  [ -n "${MATHWORKS_TOKEN}" ]; then
    activationFlag="--skip-activation"
fi

downloadAndRun https://ssd.mathworks.com/supportfiles/ci/ephemeral-matlab/v0/ci-install.sh --release ${PARAM_RELEASE} $activationFlag

# install matlab-batch
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    batchInstallDir='C:\Program Files\matlab-batch'
else
    batchInstallDir='/opt/matlab-batch'
fi

downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v0/install.sh "$batchInstallDir"

# add MATLAB and matlab-batch to path
tmpdir=$(dirname "$(mktemp -u)")
rootdir=$(cat "$tmpdir/ephemeral_matlab_root")

echo 'export PATH="'$rootdir'/bin:'$batchInstallDir':$PATH"' >> $BASH_ENV
