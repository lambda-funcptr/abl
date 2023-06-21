#!/bin/bash

pushd $(dirname $0) > /dev/null

mkdir -p dist

# build the go binary...
bash go/build.sh

echo ">>> Building initramfs image..."

podman run --privileged -v $(pwd):/config:ro -v $(pwd)/dist:/output -it funcptr/summitkit

popd > /dev/null