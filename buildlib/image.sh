image_chroot_setup() {
    # Bind resolvconf
    sudo touch "${rootfs_target}/etc/resolv.conf"
    mount -o ro,bind /etc/resolv.conf "${rootfs_target}/etc/resolv.conf"

    sudo mkdir -p ${rootfs_target}/dev
    sudo mknod -m 666 ${rootfs_target}/dev/full c 1 7
    sudo mknod -m 666 ${rootfs_target}/dev/ptmx c 5 2
    sudo mknod -m 644 ${rootfs_target}/dev/random c 1 8
    sudo mknod -m 644 ${rootfs_target}/dev/urandom c 1 9
    sudo mknod -m 666 ${rootfs_target}/dev/zero c 1 5
    sudo mknod -m 666 ${rootfs_target}/dev/tty c 5 0
    sudo mount -t proc none "${rootfs_target}/proc"
    sudo mount -o bind /sys "${rootfs_target}/sys"
}

image_chroot_exec() {
    command_string=$(echo "$@")

    sudo chroot "${rootfs_target}" /bin/sh -c "source /etc/profile; ${command_string}"
}

image_chroot_shell() {
    sudo image_chroot_exec "/bin/sh"
}

image_apk_strap() {
    echo "Running apkstrap in ${rootfs_target}..."
    sudo ${abl_workdir}/build/sbin/apk.static -X ${apk_repo}/edge/main -X ${apk_repo}/edge/community -X ${apk_repo}/edge/testing -U  --allow-untrusted -p ${rootfs_target} --initdb $(echo "$@")
}

image_chroot_destroy() {
    sudo rm -Rf "${rootfs_target}/dev"  || true
    sudo umount "${rootfs_target}/proc" || true
    sudo umount "${rootfs_target}/sys"  || true
    sudo umount "${rootfs_target}/etc/resolv.conf" || true
}
