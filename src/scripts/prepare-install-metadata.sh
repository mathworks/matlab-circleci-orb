#!/bin/bash

mkdir -p ~/.matlab-circleci-orb
eval "$UTILS"
eval "$RESOLVE_RELEASE"
# shellcheck disable=SC2154
echo "export RELEASE=\"$mpmrelease\"" > ~/.matlab-circleci-orb/install-metadata.sh
# shellcheck disable=SC2154
echo "export RELEASE_STATUS=\"$releasestatus\"" >> ~/.matlab-circleci-orb/install-metadata.sh
SORTED_PRODUCTS=$(echo "$PARAM_PRODUCTS" | tr ' ' '\n' | sort | xargs)
echo "export PRODUCTS=\"$SORTED_PRODUCTS\"" >> ~/.matlab-circleci-orb/install-metadata.sh
