#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

qemu-system-x86_64 -m 2G -bios /usr/share/ovmf/x64/OVMF.fd -enable-kvm -kernel ${workdir}/dist/abl
