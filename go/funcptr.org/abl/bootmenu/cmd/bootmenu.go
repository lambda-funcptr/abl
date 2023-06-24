package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"funcptr.org/abl/bootmenu/internal"
)

func main() {
	// Clear the screen
	clearCmd := exec.Command("clear")
	clearCmd.Stdout = os.Stdout
	_ = clearCmd.Run()

	var bdentries []string

	cmd := exec.Command("blkid")

	if stdout, err := cmd.Output(); err != nil {
		bdentries = make([]string, 0)
	} else {
		bdentries = strings.Split(strings.TrimSpace(string(stdout[:])), "\n")
	}
	
	var devices = bootmenu.ParseBlkid(bdentries)

	abl_volume_found := false
	var abl_volume map[string]string

	for _, device := range devices {
		label, exists := device["LABEL"]

		if exists && label == "ABL" {
			fmt.Println(fmt.Sprintf("Discovered ABL boot volume: %v", device["PATH"]))
			fmt.Println(fmt.Sprintf("\t%v", device))
			abl_volume_found = true
			abl_volume = device

			break
		}
	}

	if !abl_volume_found {
		fmt.Println("ABL boot volume not found or of unknown type!")
		abl_volume = bootmenu.SelectBootVolume(devices)
		abl_volume_found = true
	}

	if abl_volume_found {
		vol_type, exists := abl_volume["TYPE"]
		if ! exists || vol_type == "crypto_LUKS" {
			abl_volume = bootmenu.UnlockVolume(abl_volume)
			abl_volume_found = false
		}
	}

	fmt.Println("Mounting boot volume ", abl_volume["PATH"])

	if !bootmenu.MountVolume(abl_volume) {
		fmt.Println("Unable to mount ABL boot volume!")
		os.Exit(1)
	}

	boot_options := bootmenu.ListCfg()
	bootmenu.SelectBootOption(boot_options)
}