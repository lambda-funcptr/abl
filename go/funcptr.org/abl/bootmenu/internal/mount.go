package bootmenu

import (
	"fmt"
	"os/exec"
	"os"
	"strings"
	"syscall"
)

// Returns a new volume with the mapped device
func UnlockVolume(volume map[string]string) map[string]string {
	_ = exec.Command("cryptsetup", "close", "ABL").Run()

	cmd := exec.Command("cryptsetup", "luksOpen", volume["PATH"], "ABL")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	err := cmd.Run()

	var bdentries []string
	stdout, _ := exec.Command("blkid", "/dev/mapper/ABL").Output()

	bdentries = strings.Split(strings.TrimSpace(string(stdout[:])), "\n")

	if err != nil && len(bdentries) == 0 {
		fmt.Println(fmt.Sprintf("Unable to open LUKS partition on %v", volume["PATH"]))
		os.Exit(1)
	}

	return ParseBlkid(bdentries)[0]
}

func MountVolume(volume map[string]string) bool {
	_ = os.MkdirAll("/mnt/boot", 0700)

	_ = syscall.Unmount("/mnt/boot", 0) // Throw an unmount in, we don't care if it doesn't work...

	// We don't want to allow reads, atime, and certainly not exec from these files
	mount_opts := uintptr(syscall.MS_RDONLY | syscall.MS_NOATIME | syscall.MS_NOEXEC)

	err := syscall.Mount(volume["PATH"], "/mnt/boot", volume["TYPE"], mount_opts, "")

	if err != nil {
		fmt.Println(fmt.Sprintf("Unable to mount: %s", volume["PATH"]))
		fmt.Println(fmt.Sprintf("ERROR: %s", err))
	}

	if _, err := os.Stat("/mnt/boot/abl/"); os.IsNotExist(err) {
		fmt.Println(fmt.Sprintf("%s does not contain a valid abl directory.", volume["PATH"]))
		_ = syscall.Unmount("/mnt/boot", 0)
		return false
	}

	return err == nil
}
