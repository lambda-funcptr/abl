#!/bin/sh

set +m

seconds=$(cat /proc/uptime | cut -d " " -f1)
echo "Boot in $(echo $seconds)s."