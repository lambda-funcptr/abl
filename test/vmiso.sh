#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

qemu-system-x86_64 -smbios type=0,uefi=on -bios /usr/share/ovmf/x64/OVMF.fd -enable-kvm -m 4G -drive file=${workdir}/test/images/esp.fat -drive file=${workdir}/test/images/ubuntu.img