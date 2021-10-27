
kernel_config() {
    mkdir -p "${abl_workdir}/build/kbuild"
    
    echo "Applying custom kernel configuration. You may need to update some config options."
    cp "${abl_workdir}/kconfig" "${abl_workdir}/build/kbuild/.config"

    make -C "${abl_workdir}/build/kernel" O="${abl_workdir}/build/kbuild" oldconfig && make -C "${abl_workdir}/build/kernel" O="${abl_workdir}/build/kbuild" prepare

    read -p "Further configure kernel? [y/N] " -n 1 -r menu_config
    echo

    case "${menu_config}" in
        [Yy]* ) echo "Running menuconfig..."; make -C "${abl_workdir}/build/kernel" O="${abl_workdir}/build/kbuild" menuconfig; cp "${abl_workdir}/build/kbuild/.config" kconfig;;
        * ) echo "Skipping kernel configuration...";;
    esac
}