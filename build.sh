#!/bin/bash

pushd $(dirname $0) > /dev/null

mkdir -p dist

# build the go binary...
bash go/build.sh

echo ">>> Building initramfs image..."

podman run --privileged -v $(pwd):/config:ro -v $(pwd)/dist:/output -it funcptr/summitkit

echo ">>> Building UKI..."

podman run --privileged -v $(pwd):/config:ro -v $(pwd)/dist:/output -it $(podman build -q -f mkuki.dockerfile)

popd > /dev/null