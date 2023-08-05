#!/bin/bash

# Function to display the countdown timer with colors
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

# Set the duration of the countdown (in seconds)
countdown_duration=60

# Call the countdown timer function with the specified duration
countdown_timer $countdown_duration
