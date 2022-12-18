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
	_ = os.MkdirAll("/mnt/abl", 0700)

	err := syscall.Mount(volume["PATH"], "/mnt/abl", volume["TYPE"], 0, "")

	return err == nil
}