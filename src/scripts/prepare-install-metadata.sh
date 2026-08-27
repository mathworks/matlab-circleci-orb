#!/bin/bash

mkdir -p ~/.matlab-circleci-orb
eval "$UTILS"

mpmrelease=""
parsedrelease=$(echo "$PARAM_RELEASE" | tr '[:upper:]' '[:lower:]')
if [[ "$parsedrelease" = "latest" ]]; then
    mpmrelease=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest)
elif [[ "$parsedrelease" = "latest-including-prerelease" ]]; then
    mpmrelease=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest-including-prerelease)
else
    mpmrelease="$parsedrelease"
fi

if [[ "$mpmrelease" < "r2020b" ]]; then
    echo "Release '${mpmrelease}' is not supported. Use 'R2020b' or a later release." >&2
    exit 1
fi

echo "export RELEASE=\"$mpmrelease\"" > ~/.matlab-circleci-orb/install-metadata.sh
SORTED_PRODUCTS=$(echo "$PARAM_PRODUCTS" | tr ' ' '\n' | sort | xargs)
echo "export PRODUCTS=\"$SORTED_PRODUCTS\"" >> ~/.matlab-circleci-orb/install-metadata.sh
