#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

output_folder=""

countdown_duration=3600
countdown_timer() {
    local seconds=$1

    while [ $seconds -gt 0 ]; do
        printf "\r\033[1;33mTime remaining: \033[1;36m%02d:%02d:%02d\033[0m" $((seconds/3600)) $(((seconds/60)%60)) $((seconds%60))
        sleep 1
        ((seconds--))
    done

    echo
    echo "\033[1;32mTime's up!\033[0m"
}

while : 
do
	while getopts ":d:f:" opt; do
	    case $opt in
	        d)
	            target="$OPTARG"
	            output_folder="$target"
	            ;;
	        f)
	            input_file="$OPTARG"
	            if [ ! -f "$input_file" ]; then
	                echo -e "${RED}Error: Input file not found.${NC}"
	                exit 1
	            fi
	            output_folder="${input_file%.*}"
	            ;;
	        \?)
	            echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
	            exit 1
	            ;;
	        :)
	            echo -e "${RED}Option -$OPTARG requires an argument.${NC}" >&2
	            exit 1
	            ;;
	    esac
	done

	if [ -z "$target" ] && [ -z "$input_file" ]; then
	    echo -e "Usage: $0 [-d domain] [-f file.txt]"
	    exit 1
	fi

	if [ ! -d "$output_folder" ]; then
	    mkdir "$output_folder"
	    echo -e "Folder '${GREEN}$output_folder${NC}' created successfully."
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
	    echo -e "\n${GREEN}Processing domain: $target${NC}"

	    echo -e "${GREEN}Running Subfinder on $target${NC}"
	    subfinder -d "$target" -all -o "$output_folder/$target-subfinder.txt"

	    echo -e "${GREEN}Running assetfinder on $target${NC}"
	    assetfinder "$target" | grep "$target" > "$output_folder/$target-assetfinder.txt"

	    echo -e "${GREEN}Running Amass on $target${NC}"
	    amass enum -passive -d "$target" -o "$output_folder/$target-amass.txt"

	    echo -e "${GREEN}Running Knockpy on $target${NC}"
	    knockpy "$target" | grep -oE '[[:alnum:].-]+\.$grep_domain' > "$output_folder/$target-knockpy.txt"

	    echo -e "${GREEN}Running Findomain on $target${NC}"
	    findomain --quiet -t "$target" > "$output_folder/$target-findomain.txt"

	    echo -e "${GREEN}Running crt.sh on $target${NC}"
	    crt.sh -d "$target" > "$output_folder/$target-crt.txt"

		echo -e "\n${GREEN}Removing Duplicates and Combining all files to all.txt${NC}"
		# notify
		cat "$output_folder/"* | grep "$target" | tee -a "$output_folder/all.txt"
	done


	cat "$output_folder/all.txt" | anew "$output_folder/new_subdomains.txt" >> diff_subdomains.txt
	echo "# New Subdomains discovered:" | notify -provider slack
	cat  diff_subdomains.txt | notify -bulk -provider slack
	echo -e "${GREEN}Checking for live domains${NC}"

	cat "$output_folder/all.txt" | httpx > live.txt && cat live.txt | gau | grep "nextpage=" | notify
	
	#notify
	echo "# Changes in subdomains:" | notify -provider slack
	cat "$output_folder/all.txt" | httpx -sc -cl -location -title | tee -a "$output_folder/changes.txt"
	cat "$output_folder/changes.txt" | anew "$output_folder/httpx.txt" | notify -provider slack -bulk
	echo -e "${GREEN}Stored all live URLs to $output_folder/httpx.txt${NC}"

	echo "Running xss.sh on diff_subdomains.txt"
	xss.sh "$output_folder/changes.txt" xss_result

	echo "Running sqli.sh on diff_subdomains.txt"
	sqli.sh "$output_folder/changes.txt" sqli_result

	echo "Removing Unwanted Files..."
	for target in "${domains[@]}"; do
	    rm -rf "$output_folder/$target"*
	done

	echo -e "\n${YELLOW}Subdomain Enumeration Finished${NC}"
	countdown_timer $countdown_duration
done
