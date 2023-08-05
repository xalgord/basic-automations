#!/bin/bash

progress_bar() {
    local duration=${1:-10}*2   # Total duration of the progress bar in seconds (default: 10 seconds)
    local interval=${2:-0.5}  # Update interval in seconds (default: 0.5 seconds)

    local elapsed=0
    local progress=0
    local cols=$(tput cols)
    local total_hashes=$((cols - 12))  # Leave space for the percentage and brackets
	color_green="\033[32m"
	color_reset="\033[0m"
    while ((elapsed < duration)); do
        ((elapsed++))
        sleep "$interval"

        # Calculate progress percentage and the number of hashes to display
        progress=$((elapsed * 100 / duration))
        hashes=$((progress * total_hashes / 100))

        # Create the progress bar string
        bar=""
        for ((i = 0; i < hashes; i++)); do
            bar+=">"
        done

        # Print the progress bar
        printf "\r[${color_green}%-${total_hashes}s${color_reset}] ${color_green}%3d%%${color_reset}" "$bar" "$progress"
    done

    printf "\n"
}


# Usage example
progress_bar 10 0.5  # Will run the progress bar for 10 seconds with an update interval of 0.5 seconds
