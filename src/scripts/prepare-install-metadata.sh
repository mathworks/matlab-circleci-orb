#!/bin/bash

mkdir -p ~/.matlab-circleci-orb
eval "$UTILS"
eval "$RESOLVE_RELEASE_SH"
# shellcheck disable=SC2154
echo "export RELEASE=\"$mpmrelease\"" > ~/.matlab-circleci-orb/install-metadata.sh
# shellcheck disable=SC2154
echo "export RELEASE_STATUS=\"$releasestatus\"" >> ~/.matlab-circleci-orb/install-metadata.sh
SORTED_PRODUCTS=$(echo "<< parameters.products >>" | tr ' ' '\n' | sort | xargs)
echo "export PRODUCTS=\"$SORTED_PRODUCTS\"" >> ~/.matlab-circleci-orb/install-metadata.sh
# Debug:
echo "DEBUG: Created metadata file with contents:"
cat ~/.matlab-circleci-orb/install-metadata.sh
echo "DEBUG: End of metadata file"
