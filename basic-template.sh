#!/bin/bash

# This script was written to scan CVE-2023-24488 vulnerability
targets="$1"
mkdir ~/targets/result
while IFS= read -r url; do
	echo "Performing subdomain enumeration on $url"
	subfinder -d $url -all -o ~/targets/result/$url.txt
	echo "Running Nuclei on $url"
	cat ~/targets/result/$url.txt | nuclei -t ~/nuclei-templates/CVE-2023-24488.yaml | notify
done < "$targets"
