#!/bin/bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

sudoIfAvailable() {
    if command -v sudo >/dev/null 2>&1; then
        sudo -E bash "$@"
    else
        bash "$@"
    fi
}

stream() {
    local url="$1"
    local status=0

    if command -v wget >/dev/null 2>&1; then
        wget --retry-connrefused --waitretry=5 -qO- "$url" || status=$?
    elif command -v curl >/dev/null 2>&1; then
        curl --retry 5 --retry-connrefused --retry-delay 5 -sSL "$url" || status=$?
    else
        echo "Could not find wget or curl command" >&2
        return 1
    fi

    if [ $status -ne 0 ]; then
        echo "Error streaming file from $url" >&2
    fi

    return $status
}

download() {
    local url="$1"
    local filename="$2"
    local status=0
    
    if command -v wget >/dev/null 2>&1; then
        wget --retry-connrefused --waitretry=5 -qO "$filename" "$url" 2>&1 || status=$?
    elif command -v curl >/dev/null 2>&1; then
        curl --retry 5 --retry-all-errors --retry-delay 5 -sSLo "$filename" "$url" || status=$?
    else
        echo "Could not find wget or curl command" >&2
        return 1
    fi

    if [ $status -ne 0 ]; then
        echo "Error downloading file from $url to $filename" >&2
    fi
    
    return $status
}

os=$(uname)
arch=$(uname -m)
binext=""
# tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'install')
tmpdir="$(pwd)/install"
mkdir -p "$tmpdir"
rootdir="$tmpdir/matlab_root"
batchdir="$tmpdir/matlab-batch"
mpmdir="$tmpdir/mpm"
batchbaseurl="https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v1"
mpmbaseurl="https://www.mathworks.com/mpm"
releasestatus=""

# resolve release
parsedrelease=$(echo "$PARAM_RELEASE" | tr '[:upper:]' '[:lower:]')
if [[ "$parsedrelease" = "latest" ]]; then
    mpmrelease=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest)
elif [[ "$parsedrelease" = "latest-including-prerelease" ]]; then
    mpmrelease=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest-including-prerelease)
    releasestatus="--release-status=Prerelease"
else
    mpmrelease="$parsedrelease"
fi

# validate release is supported
if [[ "$mpmrelease" < "r2020b" ]]; then
    echo "Release '${mpmrelease}' is not supported. Use 'R2020b' or a later release.">&2
    exit 1
fi

# install system dependencies
if [[ "$os" = "Linux" ]]; then
    # install MATLAB dependencies
    release=$(echo "${mpmrelease}" | grep -ioE "(r[0-9]{4}[a-b])")
    stream https://ssd.mathworks.com/supportfiles/ci/matlab-deps/v0/install.sh | sudoIfAvailable -s -- "$release"
    # install mpm depencencies
    sudoIfAvailable -c "apt-get install --no-install-recommends --no-upgrade --yes \
        wget \
        unzip \
        ca-certificates"
elif [[ "$os" = "Darwin" && "$arch" = "arm64" ]]; then
    if [[ "$mpmrelease" < "r2023b" ]]; then
        # install Rosetta 2
        sudoIfAvailable -c "softwareupdate --install-rosetta --agree-to-license"
    else
        # install Java runtime
        jdkpkg="$tmpdir/jdk.pkg"
        download https://corretto.aws/downloads/latest/amazon-corretto-8-aarch64-macos-jdk.pkg "$jdkpkg"
        sudoIfAvailable -c "installer -pkg '$jdkpkg' -target /"
    fi
fi

# set os specific options
if [[ "$os" = CYGWIN* || "$os" = MINGW* || "$os" = MSYS* ]]; then
    mwarch="win64"
    binext=".exe"
    rootdir=$(cygpath "$rootdir")
    mpmdir=$(cygpath "$mpmdir")
    batchdir=$(cygpath "$batchdir")
elif [[ "$os" = "Darwin" ]]; then
    if [[ "$arch" = "arm64" && ! "$mpmrelease" < "r2023b" ]]; then
         mwarch="maca64"
     else
         mwarch="maci64"
     fi
    rootdir="$rootdir/MATLAB.app"
    sudoIfAvailable -c "launchctl limit maxfiles 65536 200000" # g3185941
else
    mwarch="glnxa64"
fi

# Short-circuit if everything already exists and CACHE_ENABLED is true
if [[ "${CACHE_ENABLED:-false}" == "true" && -x "$mpmdir/mpm$binext" && -x "$batchdir/matlab-batch$binext" && -x "$rootdir/bin/matlab" ]]; then
    echo "CACHE_ENABLED is true and MATLAB, matlab-batch, and mpm already exist. Skipping installation."
    echo 'export PATH="'$rootdir'/bin:'$batchdir':$PATH"' >> $BASH_ENV
    if [[ "$mwarch" = "win64" ]]; then
        echo 'export PATH="'$rootdir'/runtime/'$mwarch':$PATH"' >> $BASH_ENV
    fi
    # Ensure install/ is owned by the current user to avoid permission issues in later steps like run-tests
    sudoIfAvailable -c "chown -R $(id -u):$(id -g) '$tmpdir'" || true
    exit 0
fi

mkdir -p "$rootdir"
mkdir -p "$batchdir"
mkdir -p "$mpmdir"

# install mpm
download "$mpmbaseurl/$mwarch/mpm" "$mpmdir/mpm$binext"
chmod +x "$mpmdir/mpm$binext"

# install matlab-batch
download "$batchbaseurl/$mwarch/matlab-batch$binext" "$batchdir/matlab-batch$binext"
chmod +x "$batchdir/matlab-batch$binext"

# install matlab
"$mpmdir/mpm$binext" install \
    --release="$mpmrelease" \
    --destination="$rootdir" \
    ${releasestatus} \
    --products ${PARAM_PRODUCTS} MATLAB

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchdir':$PATH"' >> $BASH_ENV

# add MATLAB Runtime to path for windows
if [[ "$mwarch" = "win64" ]]; then
    echo 'export PATH="'$rootdir'/runtime/'$mwarch':$PATH"' >> $BASH_ENV
fi

# Ensure install/ is owned by the current user to avoid permission issues in later steps like run-tests
sudoIfAvailable -c "chown -R $(id -u):$(id -g) '$tmpdir'" || true