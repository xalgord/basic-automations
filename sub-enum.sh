#!/bin/bash

target="$1"
output_folder="$target"
if [ ! -d "$output_folder" ]; then
    mkdir "$output_folder"
    echo "Folder '$output_folder' created successfully."
grep_domain=$(echo "$target" | grep -oE '[^.]+[.][^.]+$' | awk -F '.' '{print $NF}')
fi
# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Running Subfinder on $target${NC}"
# subfinder -d "$target" -all -o "$output_folder/subfinder.txt"

echo -e "${GREEN}Running assetfinder on $target${NC}"
# assetfinder "$target" | grep "$target" > "$output_folder/assetfinder.txt"

echo -e "${GREEN}Running Amass on $target${NC}"
# amass enum -passive -d "$target" -o "$output_folder/amass.txt"

echo -e "${GREEN}Running Knockpy on $target${NC}"
knockpy "$target" | grep -oE '[[:alnum:].-]+\.$grep_domain' > "$output_folder/knockpy.txt"

echo -e "${GREEN}Removing Duplicates and Combining all files to all.txt${NC}"
cat "$output_folder"/* | sort -u > "$output_folder/all.txt"

echo -e "${GREEN}Checking for live domains${NC}"
cat "$output_folder/all.txt" | httpx > "$output_folder/httpx.txt"
echo -e "${GREEN}Stored all live URLs to $output_folder/httpx.txt${NC}"

echo -e "${YELLOW}Subdomain Enumeration Finished${NC}"
