tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'run-command')

# download run command shell scripts
curl -sfLo "${tmpdir}/run-matlab-command.zip" https://ssd.mathworks.com/supportfiles/ci/run-matlab-command/v0/run-matlab-command.zip
unzip -qod "${tmpdir}/bin" "${tmpdir}/run-matlab-command.zip"

# form OS appropriate paths for MATLAB
os=$(uname)
workdir=$(pwd)
scriptdir=$tmpdir
if [[ $os = CYGWIN* || $os = MINGW* || $os = MSYS* ]]; then
    workdir=$(cygpath -w "$workdir")
    scriptdir=$(cygpath -w "$scriptdir")
fi

# create script to execute
script=command_${RANDOM}
scriptpath=${tmpdir}/${script}.m
echo "cd('${workdir//\'/\'\'}');" > "$scriptpath"
cat << EOF >> "$scriptpath"
${PARAM_COMMAND}
EOF

# run MATLAB command
"${tmpdir}/bin/run_matlab_command.sh" "cd('${scriptdir//\'/\'\'}'); $script"
