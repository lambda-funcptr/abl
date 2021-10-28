#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

qemu-system-x86_64 -enable-kvm -kernel ${workdir}/dist/abl -m 4G ${workdir}/test/images/ubuntu.img