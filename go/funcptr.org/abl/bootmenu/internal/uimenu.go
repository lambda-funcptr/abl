package bootmenu

import (
	"fmt"
	"strings"
	"syscall"
	"github.com/pterm/pterm"
)

func describeDevices(devices []map[string]string) []string {
	descriptors := make([]string, len(devices))

	for index, device := range devices {
		var description strings.Builder

		description.WriteString(device["PATH"])
		description.WriteString(" => ")
		description.WriteString(fmt.Sprintf("%v", device))

		descriptors[index] = description.String()
	}

	return descriptors
}

func SelectBootVolume(devices []map[string]string) map[string]string {
	if len(devices) == 0 {
		fmt.Println("No block devices detected, dropping into shell...")
		syscall.Exec("/bin/busybox", []string{"ash"}, nil)
	}

	result, _ := pterm.DefaultInteractiveSelect.WithOptions(describeDevices(devices)).Show("Please Select ABL Boot Volume")

	devPath, _, _ := strings.Cut(result, " => ")

	for _, device := range devices {
		if device["PATH"] == devPath {
			return device
		}
	}

	return nil
}