#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

if ! [ -e "${workdir}/test/images/ubuntu.img" ]; then
  wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img -O ${workdir}/test/images/ubuntu.img
fi

pushd "${workdir}/test" > /dev/null

rm images/esp.fat
touch images/esp.fat
fallocate -z -l 32M images/esp.fat
mformat -i images/esp.fat ::
mcopy -s -i images/esp.fat esp/EFI ::
mcopy -i images/esp.fat ../dist/abl.efi ::/EFI/boot/bootx64.efi

popd > /dev/null