#!/bin/bash

# This script was written to scan CVE-2023-24488 vulnerability
targets="$1"

while IFS= read -r url; do
	echo "creating directory for $url"
	if [ -d "~/targets/$url" ]; then
		echo "Folder $url already exists."
	else
		mkdir ~/targets/$url
	fi
	echo "reached"
done < "$targets"
