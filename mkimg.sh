#!/bin/bash

set -e

abl_workdir="$(git rev-parse --show-toplevel)"
rootfs_target="${abl_workdir}/build/root"

source "${abl_workdir}/buildlib/dependencies.sh"
source "${abl_workdir}/buildlib/image.sh"
source "${abl_workdir}/buildlib/kernel.sh"

source "${abl_workdir}/ablvars"

sudo -l

build_image() {
    vars_changed=false

    if cmp -s "${abl_workdir}/ablvars" "${abl_workdir}/build/ablvars"; then
        vars_changed=false;
    else
        vars_changed=true;
    fi

    clean_project="n"
    if $vars_changed; then
        echo "Cleaning project due to config change..."
        clean_project="Y"
    else
        read -p "Do you wish to clean the project? [y/N] " -n 1 -r clean_project
        echo
    fi

    case "${clean_project}" in
        [Yy]* ) echo "Cleaning..."; clean;;
        * ) echo "Continuing with old files...";;
    esac

    mkdir -p "${abl_workdir}/build"

    cp ${abl_workdir}/ablvars ${abl_workdir}/build/ablvars

    rm -rf ${abl_workdir}/dist || true

    echo "Building bootmenu..."
    cd bootmenu; make
    cd ..;

    echo "Copying over bootmenu binary"
    sudo mkdir -p  "${abl_workdir}/build/root/sbin"
    sudo cp "${abl_workdir}/bootmenu/build/bootmenu" "${abl_workdir}/build/root/sbin/bootmenu"

    boostrap_image

    build_kernel
}

boostrap_image() {
    echo "======================"
    echo "Bootstraping rootfs..."
    echo "======================"
    image_apk_strap add alpine-base
    image_apk_strap add ${abl_pkgs}

    echo "Patching bootroot with custom modifications..."
    sudo rsync -a --chown root:root "${abl_workdir}/overlay/" "${abl_workdir}/build/root"

    echo "Configuring open-rc init tasks"
    image_chroot_exec 'rc-update add mdev sysinit'
    image_chroot_exec 'rc-update add syslog boot'
    image_chroot_exec 'rc-update add mount-ro shutdown'
    image_chroot_exec 'rc-update add killprocs shutdown'

    image_chroot_exec 'echo "abl" > /etc/hostname'
}

build_kernel() {
    echo "====================="
    echo "Configuring kernel..."
    echo "====================="

    kernel_config

    echo "===================="
    echo "Compiling kernel..."
    echo "===================="

    sudo make -C "${abl_workdir}/build/kernel" O="${abl_workdir}/build/kbuild" -j$(nproc) bzImage

    mkdir -p "${abl_workdir}/dist"    
    cp "${abl_workdir}/build/kbuild/arch/x86_64/boot/bzImage" "${abl_workdir}/dist/abl"
}

build_image;

image_chroot_destroy;