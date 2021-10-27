clean () {
    sudo rm -rf "${abl_workdir}/build" || true

    echo "Creating build directory..."
    mkdir -p "${abl_workdir}/build"

    fetch_deps

    echo "Extracting apk-tools-static..."
    tar -xzf "${abl_workdir}/build/apk-tools-static-${apk_version}.apk" -C ${abl_workdir}/build

    echo "Extracting kernel..."
    tar -xf "${abl_workdir}/build/linux-${kernel_version}.tar.xz" -C ${abl_workdir}/build
    mv "${abl_workdir}/build/linux-${kernel_version}" "${abl_workdir}/build/kernel"

    make -C ${abl_workdir}/build/kernel O="${abl_workdir}/build/kbuild" distclean
}

fetch_deps() {
    rm -f "${abl_workdir}/build/apk-tools-static-${apk_version}.apk" || true
    rm -f "${abl_workdir}/build/linux-${kernel_version}.tar.xz" || true

    echo "Fetching apk-static version ${apk_version}..."
    wget "${apk_tarball}" -O "${abl_workdir}/build/apk-tools-static-${apk_version}.apk" --show-progress

    echo "Using kernel version ${kernel_version}..."
    wget "${kernel_tarball}" -O "${abl_workdir}/build/linux-${kernel_version}.tar.xz" --show-progress
}