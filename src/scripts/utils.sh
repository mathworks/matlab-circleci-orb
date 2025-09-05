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
