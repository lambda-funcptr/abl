#!/bin/bash

source .config

set -e

pushd $(dirname $0) > /dev/null

mkdir -p dist

echo ">>> Building go binary..."

# build the go binary...
bash go/build.sh

echo ">>> Building initramfs image..."

${CRI} run --privileged -v $(pwd):/config:ro -v $(pwd)/dist:/output -it funcptr/summitkit

echo ">>> Building UKI..."

${CRI} run --privileged -v $(pwd):/config:ro -v $(pwd)/dist:/output -it $(podman build -q -f mkuki.dockerfile)

bash mktest.sh

popd > /dev/null
