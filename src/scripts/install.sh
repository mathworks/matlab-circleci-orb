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
rootdir="$tmpdir/matlab_root"
mpmbaseurl="https://www.mathworks.com/mpm"

# install system dependencies
if [[ $os = Linux ]]; then
    downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-deps/v0/install.sh "${PARAM_RELEASE}"
    # install mpm depencencies
    sudo apt-get install --no-install-recommends --yes \
        wget \
        unzip \
        ca-certificates && \
    apt-get clean && apt-get autoremove
fi

# set os specific options
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    batchInstallDir='/c/Program Files/matlab-batch'
    rootdir=$(cygpath "$rootdir")
    mpmurl="$mpmbaseurl/win64/mpm";
    mpmsetup="unzip -q $tmpdir/mpm -d $tmpdir"
    mpmPath="$tmpdir/bin/win64/mpm"
else
    batchInstallDir='/opt/matlab-batch'
    mpmurl="$mpmbaseurl/glnxa64/mpm";
    mpmPath="$tmpdir/mpm"
fi

if [[ $PARAM_RELEASE = "latest" ]]; then
    version=$(curl https://mw-ci-static-dev.s3.amazonaws.com/matlab-deps/v0/versions.json | jq .latest | tr -d '"')
else
    version=${PARAM_RELEASE}
fi

# install mpm
curl -o "$tmpdir/mpm" -sfL $mpmurl
eval $mpmsetup
chmod +x "$mpmPath"
mkdir rootdir

# install matlab
"$mpmPath" install \
    --release=$version \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB Parallel_Computing_Toolbox


# install matlab-batch
downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v0/install.sh "$batchInstallDir"

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchInstallDir':$PATH"' >> $BASH_ENV
