#!/bin/bash

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

parsedrelease=$(echo "$PARAM_RELEASE" | tr '[:upper:]' '[:lower:]')
if [[ "$parsedrelease" = "latest" ]]; then
    mpmrelease=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest)
elif [[ "$parsedrelease" = "latest-including-prerelease" ]]; then
    fetched=$(stream https://ssd.mathworks.com/supportfiles/ci/matlab-release/v0/latest-including-prerelease)
    if [[ "$fetched" == *prerelease ]]; then
        mpmrelease="${fetched%prerelease}"
        # shellcheck disable=SC2034
        releasestatus="--release-status=Prerelease"
    else
        mpmrelease="$fetched"
    fi
else
    mpmrelease="$parsedrelease"
fi

if [[ "$mpmrelease" < "r2020b" ]]; then
    echo "Release '${mpmrelease}' is not supported. Use 'R2020b' or a later release." >&2
    exit 1
fi