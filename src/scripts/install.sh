#!/usr/bin/env bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

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
tmpdir=$(dirname "$(mktemp -u)")
mpmbaseurl="https://www.mathworks.com/mpm"

# install system dependencies
if [[ $os = Linux ]]; then
    # install MATLAB dependencies
    downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-deps/v0/install.sh "${PARAM_RELEASE}"
    # install mpm depencencies
    sudo apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        ca-certificates && \
    sudo apt-get clean && sudo apt-get autoremove
fi

# set os specific options
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    batchInstallDir='/c/Program Files/matlab-batch'
    rootdir="$tmpdir/matlab_root"
    mpmurl="$mpmbaseurl/win64/mpm";
    mpmsetup="unzip -q $tmpdir/mpm -d $tmpdir"
    mpmPath="$tmpdir/bin/win64/mpm"
    rootdir=$(cygpath "$rootdir")
    mpmPath=$(cygpath "$mpmPath")
else
    rootdir="$tmpdir/matlab_root"
    batchInstallDir='/opt/matlab-batch'
    mpmurl="$mpmbaseurl/glnxa64/mpm";
    mpmsetup=""
    mpmPath="$tmpdir/mpm"
fi

# resolve release
if [[ $PARAM_RELEASE = "latest" ]]; then
    release=$(curl https://mw-ci-static-dev.s3.amazonaws.com/matlab-deps/v0/versions.json | grep "\"latest\":.*$" | sed 's/^.*latest//'  | tr -cd [:alnum:])
else
    release=${PARAM_RELEASE}
fi

# install mpm
curl -o "$tmpdir/mpm" -sfL $mpmurl
eval $mpmsetup
chmod +x "$mpmPath"
mkdir -p rootdir

# install matlab
"$mpmPath" install \
    --release=$release \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB Parallel_Computing_Toolbox

# install matlab-batch
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v0/install.sh "$batchInstallDir"

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchInstallDir':$PATH"' >> $BASH_ENV
