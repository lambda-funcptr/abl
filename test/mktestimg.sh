#!/bin/bash

workdir=$(git rev-parse --show-toplevel)

wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img -O ${workdir}/test/images/ubuntu.img