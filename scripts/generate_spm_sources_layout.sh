#!/bin/sh

set -e

SPM_SOURCES_PATH="$SOURCE_ROOT/../spm/Sources/core-plot"
SPM_PUBLIC_HEADERS_PATH="$SPM_SOURCES_PATH/include"

function cleanup() {
    echo "Delete all symbolic links from spm folder"
    echo "Deleted from $SPM_SOURCES_PATH"

    rm -rf "$SPM_PUBLIC_HEADERS_PATH"/*.[hm]
    rm -rf "$SPM_SOURCES_PATH"/*.[hm]

    echo "      Done"
    echo ""
}

function generate_spm_public_headers() {
    echo "Generate symbolic links for all public headers. *.h"
    echo "Generated under $SPM_PUBLIC_HEADERS_PATH"

    public_headers_list=$(
        find "framework" \
            -type f \
            -name "*.[h]" \
            -not -path "*/build/*" \
            -not -path "*/MacOnly/*" \
            -not -path "framework/CorePlot.h" \
            -not -path "framework/CocoaPods/CorePlot.h" \
            -not -name "*Test*.[hm]" \
            -not -name "_*.[hm]" \
            -not -name "mainpage.h" \
        | sed "s| \([^/]\)|:\1|g"
    )

    SRC_ROOT="$(pwd)"

    mkdir -p "$SPM_PUBLIC_HEADERS_PATH"
    cd "$SPM_PUBLIC_HEADERS_PATH"

    for public_file in $public_headers_list; do
        file_to_link=$(echo "$public_file" | sed "s|:| |g")
        ln -s "../../../../$file_to_link"

    done

    cd "$SRC_ROOT"

    echo "      Done"
    echo ""
}

function generate_spm_private_sources() {
    echo "Generate symbolic links for all private headers/implementations. _*.h && _*.m"
    echo "Generated under $SPM_SOURCES_PATH"

    private_sources_list=$(
        find "framework" \
            -type f \
            -name "_*.[mh]" \
            -not -path "*/build/*" \
            -not -path "*/MacOnly/*" \
        | sed "s| \([^/]\)|:\1|g"
    )

    SRC_ROOT="$(pwd)"

    mkdir -p "$SPM_SOURCES_PATH"
    cd "$SPM_SOURCES_PATH"

    for private_file in $private_sources_list; do
        file_to_link=$(echo "$private_file" | sed "s|:| |g")

        ln -s "../../../$file_to_link"

    done

    cd "$SRC_ROOT"

    echo "      Done"
    echo ""
}

function generate_spm_public_sources() {
    echo "Generate symbolic links for all public implementations. *.m"
    echo "Generated under $SPM_SOURCES_PATH"

    public_sources_list=$(
        find "framework" \
            -type f \
            -name "*.[m]" \
            -not -path "*/build/*" \
            -not -path "*/MacOnly/*" \
            -not -path "framework/CorePlot.h" \
            -not -path "framework/CocoaPods/CorePlot.h" \
            -not -name "*Test*.[hm]" \
            -not -name "_*.[hm]" \
        | sed "s| \([^/]\)|:\1|g"
    )

    SRC_ROOT="$(pwd)"

    mkdir -p "$SPM_SOURCES_PATH"
    cd "$SPM_SOURCES_PATH"

    for public_file in $public_sources_list; do
        file_to_link=$(echo "$public_file" | sed "s|:| |g")
        ln -s "../../../$file_to_link"

    done

    cd "$SRC_ROOT"

    echo "      Done"
    echo ""
}

########## SPM generator pipeline #############
#0
cd ..
#1
cleanup
#2
generate_spm_public_headers
#3
generate_spm_private_sources
#4
generate_spm_public_sources
