#!/bin/bash -e

{ [[ -e .config ]] && source .config; } || true
CIR="${CRI:-docker}"

pushd $(dirname $0) > /dev/null

run_flags="--rm -it --tmpfs /tmp/abl -v ./dist:/tmp/dist:z"

function build_tool_container {
    if [[ $($CRI image list --format json abl-buildtool:latest) == "[]" ]]; then
        $CRI build -t abl-buildtool -f buildtool.dockerfile
    fi
}

function clean {
    echo "Pruning old ABL build tool..."
    $CRI image rm abl-buildtool:latest || true
    echo "Cleaning dist directory..."
#    rm -rf dist
    mkdir -p dist
}

if [[ "$1" == "debug" ]]; then
    run_flags="${run_flags} -v .:/opt/abl:ro"
    shift 1
fi

if [[ "$1" == "clean" ]]; then
    clean
    exit 0
fi

if [[ "$1" == "rebuild" ]]; then
    clean
    shift; set -- "build" "${@}"
fi

build_tool_container

$CRI run ${run_flags} abl-buildtool "${@}"