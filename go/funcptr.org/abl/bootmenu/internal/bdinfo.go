package bootmenu

import (
	"strings"
)

func parseBlkidLine(line string) map[string]string {
	data := make(map[string]string)

	path, tags, _ := strings.Cut(line, ":")
	
	data["PATH"] = path

	tag_data := strings.Fields(tags)

	for _, tag := range tag_data {
		tag, value, _ := strings.Cut(tag, "=")
		value_inner := strings.Trim(value, "\" ")

		if tag == "BLOCK_SIZE" {
			continue
		}

		data[tag] = value_inner
	}

	return data
}

func ParseBlkid(blkidOut []string) []map[string]string {
	lines := blkidOut

	out := make([]map[string]string, len(lines))
	for index, line := range lines {
		out[index] = parseBlkidLine(line)
	}
	return out
}