#!/usr/bin/env bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

sudoIfAvailable() {
    if [[ -x $(command -v sudo) ]]; then
    sudo -E bash "$@"
    else
    bash "$@"
    fi
}

downloadAndRun() {
    url=$1
    shift
    curl -sfL $url | sudoIfAvailable -s -- "$@"
}

os=$(uname)
tmpdir=$(dirname "$(mktemp -u)")
rootdir="$tmpdir/matlab_root"
mpmbaseurl="https://www.mathworks.com/mpm"

# install system dependencies
if [[ $os = Linux ]]; then
    # install MATLAB dependencies
    release=$(echo "${PARAM_RELEASE}" | grep -ioE "(r[0-9]{4}[a-b]|latest)")
    downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-deps/v0/install.sh "$release"
    # install mpm depencencies
    sudoIfAvailable -c "apt-get install --no-install-recommends --no-upgrade --yes \
        wget \
        unzip \
        ca-certificates"
fi

# set os specific options
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    batchinstalldir='/c/Program Files/matlab-batch'
    mpmpath="$tmpdir/bin/win64/mpm"
    mpmsetup="unzip -q $tmpdir/mpm -d $tmpdir"
    mwarch="win64"

    rootdir=$(cygpath "$rootdir")
    mpmpath=$(cygpath "$mpmpath")
else
    batchinstalldir='/opt/matlab-batch'
    mpmpath="$tmpdir/mpm"
    mpmsetup=""
    mwarch="glnxa64"
fi

# resolve release
if [[ ${PARAM_RELEASE,,} = "latest" ]]; then
    mpmrelease=$(curl https://mw-ci-static-dev.s3.amazonaws.com/release-info/latest.txt)
else
    mpmrelease="${PARAM_RELEASE}"
fi

# install mpm
curl -o "$tmpdir/mpm" -sfL "$mpmbaseurl/$mwarch/mpm"
eval $mpmsetup
chmod +x "$mpmpath"
mkdir -p "$rootdir"

# install matlab
"$mpmpath" install \
    --release=$mpmrelease \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB Parallel_Computing_Toolbox

# install matlab-batch
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v0/install.sh "$batchinstalldir"

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchinstalldir':$PATH"' >> $BASH_ENV
