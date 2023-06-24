package bootmenu

import (
	"fmt"
	"os"
	"sort"
	"strings"
)

func ListCfg() /**/ []string {
	files, err := os.ReadDir("/mnt/boot/abl/")

	if err != nil {
		fmt.Println(fmt.Sprintf("Error reading configs: %s", err))

		return []string{}
	}

	valid_configs := []os.DirEntry{}

	for _, candidate_config := range files {
		if !candidate_config.IsDir() && strings.HasSuffix(candidate_config.Name(), ".bls") {
			valid_configs = append(valid_configs, candidate_config)
		}
	}

	// Files sorted by name first, then by mtime, this should be fast.
	sort.Slice(valid_configs, func (it_x int, it_y int) bool {
		return files[it_x].Name() < files[it_y].Name() 
	})

	sort.SliceStable(valid_configs, func (it_x int, it_y int) bool {
		file_info_x, _ := files[it_x].Info()
		file_info_y, _ := files[it_y].Info()
		return file_info_y.ModTime().Before(file_info_x.ModTime())
	})

	configs := []string{}

	for _, config := range valid_configs {
		configs = append(configs, config.Name())
	}

	return configs
}

func OpenCfg() /**/ {
	
}