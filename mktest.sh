#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

mkdir -p "${workdir}/test/images"

if ! [ -e "${workdir}/test/images/ubuntu.img" ]; then
  wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img -O ${workdir}/test/images/ubuntu.img
fi

pushd "${workdir}/test" > /dev/null

if ! [ -e "images/esp.fat" ]; then
  rm images/esp.fat
  touch images/esp.fat
  fallocate -z -l 32M images/esp.fat
  mformat -i images/esp.fat ::
fi

mcopy -no -s -i images/esp.fat esp/EFI ::
mcopy -no -i images/esp.fat ../dist/abl.efi ::/EFI/boot/bootx64.efi

if ! [ -e "images/bootcfg.f2fs" ]; then
  rm images/bootcfg.f2fs
  touch images/bootcfg.f2fs
  fallocate -z -l 64M images/bootcfg.f2fs
  mkfs.f2fs -l "ABL" images/bootcfg.f2fs
fi
sload.f2fs -f bootcfg images/bootcfg.f2fs

popd > /dev/null