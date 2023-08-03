#!/bin/bash

targets="$1"
folder_name="$2"
output_folder=$folder_name
mkdir "$output_folder"

while IFS= read -r url; do

	echo -e "\n\033[1;35mScanning $url\033[0m"
	
	# Run Paramspider on the URL
	echo -e "\n\033[1;36mRunning Paramspider on $url\033[0m"
	paramspider.py -d "$url" --level high -o "$output_folder/paramspider.txt"
	echo -e "\033[1;33mRunning kxss on paramspider.txt\033[0m"
	cat "$output_folder/paramspider.txt" | kxss | grep -E "['\"<>].*['\"<>].*['\"<>].*['\"<>]" | notify
	
	# # Run Gau on the URL
	# echo -e "\n\033[1;36mRunning Gau on $url\033[0m"
	# gau "$url" --o "$output_folder/gau.txt"
	# echo -e "\033[1;33mRunning kxss on gau.txt\033[0m"
	# cat "$output_folder/gau.txt" | kxss | grep -E "['\"<>].*['\"<>].*['\"<>].*['\"<>]" | notify
	
	# # Run waybackurls on the URL
	# echo -e "\n\033[1;36mRunning waybackurls on $url\033[0m"
	# waybackurls "$url" > "$output_folder/waybackurls.txt"
	# echo -e "\033[1;33mRunning kxss on waybackurls.txt\033[0m"
	# cat "$output_folder/waybackurls.txt" | kxss | grep -E "['\"<>].*['\"<>].*['\"<>].*['\"<>]" | notify
	
	# Run Katana on the URL
	# echo -e "\n\033[1;36mRunning Katana on $url\033[0m"
	# katana -u "$url" -d 5 -jc -headless -no-sandbox -kf robotstxt,sitemapxml -output "$output_folder/katana.txt"
	# echo -e "\033[1;33mRunning kxss on katana.txt\033[0m"
	# cat "$output_folder/katana.txt" | kxss | grep -E "['\"<>].*['\"<>].*['\"<>].*['\"<>]" | notify
	
	echo -e "\n\033[1;32mTask Finished!!!\033[0m"
	
	echo -e "\033[1;31mRemoving Files\033[0m"
	rm -rf "$output_folder"/*
	
done < "$targets"
