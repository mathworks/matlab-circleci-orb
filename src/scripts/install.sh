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
osext=""
tmpdir=$(dirname "$(mktemp -u)")
rootdir="$tmpdir/matlab_root"
batchdir="$tmpdir/matlab-batch"
batchbaseurl="https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v1"
mpmbaseurl="https://www.mathworks.com/mpm"

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
    osext=".exe"
    mpmpath="$tmpdir/bin/win64/mpm"
    mpmsetup="unzip -q $tmpdir/mpm -d $tmpdir"
    mwarch="win64"

    rootdir=$(cygpath "$rootdir")
    mpmpath=$(cygpath "$mpmpath")
elif [[ $os = Darwin ]]; then
    rootdir="$rootdir/MATLAB.app"
    mpmpath="$tmpdir/bin/maci64/mpm"
    mpmsetup="unzip -q $tmpdir/mpm -d $tmpdir"
    mwarch="maci64"
else
    mpmpath="$tmpdir/mpm"
    mpmsetup=""
    mwarch="glnxa64"
fi

# install mpm
curl -o "$tmpdir/mpm" -sfL "$mpmbaseurl/$mwarch/mpm"
eval $mpmsetup
chmod +x "$mpmpath"
mkdir -p "$rootdir"
mkdir -p "$batchdir"

# install matlab-batch
curl -o "$batchdir/matlab-batch" -sfL "$batchbaseurl/$mwarch/matlab-batch$osext"
chmod +x "$batchdir/matlab-batch"

# install matlab
"$mpmpath" install \
    --release=$mpmrelease \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchdir':$PATH"' >> $BASH_ENV
