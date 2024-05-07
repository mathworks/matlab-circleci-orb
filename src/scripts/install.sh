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
arch=$(uname -m)
binext=""
tmpdir=$(dirname "$(mktemp -u)")
rootdir="$tmpdir/matlab_root"
batchdir="$tmpdir/matlab-batch"
mpmdir="$tmpdir/mpm"
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
elif [[ $os = Darwin && $arch = arm64 ]]; then
    if [[ $mpmrelease < "r2023b" ]]; then
        # install Rosetta 2
        sudoIfAvailable -c "softwareupdate --install-rosetta --agree-to-license"
    else
        # install Java runtime
        jdkpkg="$tmpdir/jdk.pkg"
        curl -sfL https://corretto.aws/downloads/latest/amazon-corretto-8-aarch64-macos-jdk.pkg -o $jdkpkg
        sudoIfAvailable -c "installer -pkg $jdkpkg -target /"
    fi
fi

# set os specific options
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    mwarch="win64"
    binext=".exe"
    rootdir=$(cygpath "$rootdir")
    mpmdir=$(cygpath "$mpmdir")
    batchdir=$(cygpath "$batchdir")
elif [[ $os = Darwin ]]; then
    if [[ $arch = arm64 && ! $mpmrelease < "r2023b" ]]; then
         mwarch="maca64"
     else
         mwarch="maci64"
     fi
    rootdir="$rootdir/MATLAB.app"
    sudoIfAvailable -c "launchctl limit maxfiles 65536 200000" # g3185941
else
    mwarch="glnxa64"
fi

mkdir -p "$rootdir"
mkdir -p "$batchdir"
mkdir -p "$mpmdir"

# install mpm
curl -o "$mpmdir/mpm$binext" -sfL "$mpmbaseurl/$mwarch/mpm"
chmod +x "$mpmdir/mpm$binext"

# install matlab-batch
curl -o "$batchdir/matlab-batch$binext" -sfL "$batchbaseurl/$mwarch/matlab-batch$binext"
chmod +x "$batchdir/matlab-batch$binext"

# install matlab
"$mpmdir/mpm$binext" install \
    --release=$mpmrelease \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchdir':$PATH"' >> $BASH_ENV
