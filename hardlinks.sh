#!/bin/bash

# List of names to ignore (separated by spaces)
source_directory="/home/ghiles/.config/nvim/"
target_directory="nvim/"

ignore_list=("lazy-lock.json")


are_associated_links() {
  local file1="$1"
  local file2="$2"

  local inode1=$(stat -c "%i" "$file1")
  local inode2=$(stat -c "%i" "$file2")
  
  [ "$inode1" = "$inode2" ]
}

# Function to echo text in red
echo_red() {
  echo -e "\033[1;31m$1\033[0m"  # Red text
}

# Function to echo text in blue
echo_blue() {
  echo -e "\033[1;34m$1\033[0m"  # Blue text
}

# Function to echo text in green
echo_green() {
  echo -e "\033[1;32m$1\033[0m"  # Green text
}

# Function to echo text in orange
echo_orange() {
  echo -e "\033[1;33m$1\033[0m"  # Orange text
}



create_hard_links() {
  local source_dir="$1"
  local target_dir="$2"

  # Create the target directory if it doesn't exist
  mkdir -p "$target_dir"

  # Loop through all files and directories in the source directory
  for entry in "$source_dir"/*; do
    # Extract the name of the entry (excluding the path)
    local entry_name="$(basename "$entry")"

    # Check if the entry name is in the ignore list
    if [[ " ${ignore_list[@]} " =~ " ${entry_name} " ]]; then
	  # Echo the path of the ignored file
      echo_orange "[󰈉  Ignoring file: $entry]\n"
      continue  # Skip this entry if it's in the ignore list
    fi

    if [ -f "$entry" ]; then
	
  	  if [ -e "$target_dir/$entry_name" ]; then 
  	      	echo_orange "  [$target_dir/$entry_name exist]"
	  	    if are_associated_links "$entry" "$target_dir/$entry_name"; then
  	      		echo_green "  [$target_dir/$entry_name correctly associated]\n"
			else
  	      		echo_red "[$target_dir/$entry_name incorrectly associated]\n"
				# remove the target file if exist and not associated
				rm "$target_dir/$entry_name"
      			# If it's a file, create a hard link in the target directory
      			ln "$entry" "$target_dir/$entry_name"
	  	    fi
	  else
      		# If it's a file and does't exist, create a hard link in the target directory
  	      	echo_blue "  [$target_dir/$entry_name is created]\n"
      		ln "$entry" "$target_dir/$entry_name"
  	  fi
  
    elif [ -d "$entry" ]; then
      # If it's a directory, recursively call the function
      create_hard_links "$entry" "$target_dir/$entry_name"
    fi
  done
}

#if [ $# -ne 2 ]; then
#  echo "Usage: $0 source_directory target_directory"
#  exit 1
#fi

#source_directory="$1"
#target_directory="$2"

create_hard_links "$source_directory" "$target_directory"
echo "Hard links created from '$source_directory' to '$target_directory'"
