#!/bin/bash

output_folder=""

while getopts ":d:f:" opt; do
    case $opt in
        d)
            target="$OPTARG"
            output_folder="$target"
            ;;
        f)
            input_file="$OPTARG"
            if [ ! -f "$input_file" ]; then
                echo "Error: Input file not found."
                exit 1
            fi
            output_folder="${input_file%.*}"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [ -z "$target" ] && [ -z "$input_file" ]; then
    echo "Usage: $0 [-d domain] [-f file.txt]"
    exit 1
fi

if [ ! -d "$output_folder" ]; then
    mkdir "$output_folder"
    echo "Folder '$output_folder' created successfully."
fi

if [ -n "$target" ]; then
    # If target is provided directly, process it as a single domain
    grep_domain=$(echo "$target" | grep -oE '[^.]+[.][^.]+$' | awk -F '.' '{print $NF}')
    domains=("$target")
else
    # If input file is provided, read domains from the file
    grep_domain=""
    mapfile -t domains < "$input_file"
fi

# Process each domain one by one
for target in "${domains[@]}"; do
    echo -e "\nProcessing domain: $target"


    echo -e "${GREEN}Running Subfinder on $target${NC}"
    subfinder -d "$target" -all -o "$output_folder/$target-subfinder.txt"

    echo -e "${GREEN}Running assetfinder on $target${NC}"
    assetfinder "$target" | grep "$target" > "$output_folder/$target-assetfinder.txt"

    echo -e "${GREEN}Running Amass on $target${NC}"
    amass enum -passive -d "$target" -o "$output_folder/$target-amass.txt"

    echo -e "${GREEN}Running Knockpy on $target${NC}"
    knockpy "$target" | grep -oE '[[:alnum:].-]+\.$grep_domain' > "$output_folder/$target-knockpy.txt"

done
    echo -e "${GREEN}Removing Duplicates and Combining all files to all.txt${NC}"
    cat "$output_folder/"* | sort -u > "$output_folder/all.txt"

    echo -e "${GREEN}Checking for live domains${NC}"
    cat "$output_folder/all.txt" | httpx > "$output_folder/httpx.txt"
    echo -e "${GREEN}Stored all live URLs to $output_folder/httpx.txt${NC}"


echo "Removing Unwanted Files..."
for target in "${domains[@]}"; do
	rm -rf "$output_folder/$target"*
done

echo -e "\n${YELLOW}Subdomain Enumeration Finished${NC}"
