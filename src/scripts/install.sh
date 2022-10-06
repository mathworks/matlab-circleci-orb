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

# install matlab-batch
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    batchInstallDir='/c/Program Files/matlab-batch'
    rootdir=$(cygpath "$rootdir")
    mpmurl="$mpmbaseurl/win64/mpm";
    mpmSetup="unzip $tmpdir/mpm -d $tmpdir"
else
    batchInstallDir='/opt/matlab-batch'
    mpmurl="$mpmbaseurl/glnxa64/mpm";
    mpmSetup="mkdir $tmpdir/bin; mv $tmpdir/mpm $tmpdir/bin"
fi

# install mpm
curl -sfL $mpmUrl -O "$tmpdir"
ls $tmpdir
eval $mpmSetup
ls $tmpdir
chmod +x "$tmpdir/bin/mpm"
mkdir rootdir

"$tmpdir/bin/mpm" install \
    --release="${PARAM_RELEASE}" \
    --destination="$rootdir" \
    --products ${PARAM_PRODUCTS} MATLAB Parallel_Computing_Toolbox


downloadAndRun https://ssd.mathworks.com/supportfiles/ci/matlab-batch/v0/install.sh "$batchInstallDir"

# add MATLAB and matlab-batch to path
echo 'export PATH="'$rootdir'/bin:'$batchInstallDir':$PATH"' >> $BASH_ENV
