#!/bin/bash

# Function to show script usage
function show_usage() {
    echo "Usage: $0 <targets_file> <folder_name>"
    echo "  targets_file    Path to the file containing URLs to scan."
    echo "  folder_name     Name of the folder to store scan output."
    echo "  -h, --help      Show this help message."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
fi

# Validate command-line arguments
if [[ $# -ne 2 ]]; then
    echo "Error: Invalid number of arguments."
    show_usage
fi

targets="$1"
folder_name="$2"
output_folder=~/targets/"$folder_name"
mkdir "$output_folder"

# Function to run sqlidetector
function run_sqlidetector() {
    python3 ~/tools/SQLiDetector/sqlidetector.py -f "$1" -w 100
}

# Function to handle the signal and skip the ongoing scan
function skip_scan() {
    echo -e "\033[1;31mScan Skipped!\033[0m"
    echo -e "\033[1;31mRemoving Files\033[0m"
    rm -rf "$output_folder"/*
    continue_next_url=true
}

# Function to handle the signal and exit the script completely
function exit_script() {
    echo -e "\033[1;31mScript Exiting Gracefully!\033[0m"
    echo -e "\033[1;31mRemoving Files\033[0m"
    rm -rf "$output_folder"/*
    exit 0
}

# Trap the SIGUSR1 signal to call the skip_scan function
trap 'skip_scan' SIGUSR1

# Trap the SIGTSTP signal (Ctrl+Z) to call the exit_script function
trap 'exit_script' SIGTSTP

while IFS= read -r url; do

    echo -e "\n\033[1;35mScanning $url\033[0m"
    continue_next_url=false

    # Run Paramspider on the URL
    echo -e "\n\033[1;36mRunning Paramspider on $url\033[0m"
    paramspider.py -d "$url" --level high -o "$output_folder/paramspider.txt"
    echo -e "\033[1;33mRunning sqlidetector on paramspider.txt\033[0m"
    run_sqlidetector "$output_folder/paramspider.txt"

    if [ -e "sqli_output.txt" ]; then
        echo -e "\n\033[1;36mNotifying the Output\033[0m"
        cat "sqli_output.txt" | notify
        echo -e "\033[1;31mRemoving sqli_output.txt\033[0m"
        rm "sqli_output.txt"
    fi

    if $continue_next_url; then
        continue
    fi

    # Run Gau on the URL
    # echo -e "\n\033[1;36mRunning Gau on $url\033[0m"
    # gau "$url" --o "$output_folder/gau.txt"
    # echo -e "\033[1;33mRunning sqlidetector on gau.txt\033[0m"
    # run_sqlidetector "$output_folder/gau.txt"
    #
    # if $continue_next_url; then
    # continue
    # fi

    # Run waybackurls on the URL
    # echo -e "\n\033[1;36mRunning waybackurls on $url\033[0m"
    # waybackurls "$url" > "$output_folder/waybackurls.txt"
    # echo -e "\033[1;33mRunning sqlidetector on waybackurls.txt\033[0m"
    # run_sqlidetector "$output_folder/waybackurls.txt"

    echo -e "\n\033[1;32mTask Finished!!!\033[0m"

    echo -e "\033[1;31mRemoving Files\033[0m"
    rm -rf "$output_folder/"*

done <"$targets"
