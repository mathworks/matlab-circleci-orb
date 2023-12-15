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
binext=""

# resolve release
parsedrelease=$(echo "$PARAM_RELEASE" | tr '[:upper:]' '[:lower:]')
if [[ $parsedrelease = "latest" ]]; then
    mpmrelease=$(curl https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest)
else
    mpmrelease="${parsedrelease}"
fi

# validate release is supported
if [[ $mpmrelease < "r2020b" ]]; then
    echo "Release '${mpmrelease}' is not supported. Use 'R2020b' or a later release.">&2
    exit 1
fi

# install system dependencies
if [[ $os = Linux ]]; then
    # install MATLAB dependencies
    release=$(echo "${mpmrelease}" | grep -ioE "(r[0-9]{4}[a-b])")
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
    mwarch="win64"
    binext=".exe"
    rootdir=$(cygpath "$rootdir")
    mpmpath=$(cygpath "$mpmpath")
elif [[ $os = Darwin ]]; then
    rootdir="$rootdir/MATLAB.app"
    batchinstalldir='/opt/matlab-batch'
    mwarch="maci64"
else
    batchinstalldir='/opt/matlab-batch'
    mwarch="glnxa64"
fi

# install mpm
mpmpath="$tmpdir/mpm$binext"
curl -o "$mpmpath" -sfL "$mpmbaseurl/$mwarch/mpm"
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
