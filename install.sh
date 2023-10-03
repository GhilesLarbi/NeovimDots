#!/bin/bash

if [ -z "$XDG_CONFIG_HOME" ]; then
	CONFIG_DISTINATION="$HOME/.config/"
else 
	CONFIG_DISTINATION="$XDG_CONFIG_HOME"
fi

#echo $CONFIG_DISTINATION
#CONFIG_DISTINATION="$HOME"
#echo $CONFIG_DISTINATION

# utilitites
is_program_exist() {
    command -v "$1" >/dev/null 2>&1 && return 0
	return 1
}

# find item from array
is_item_exist() {
	local item=$1
	shift
	local arr=("$@")
	for i in "${arr[@]}"; do
		if [[ "$i" == "$item" ]];then
			return 0
		fi
	done
	return 1
}

echo_red() {
  echo -e "\033[1;31m$1\033[0m"  # Red text
}

echo_blue() {
  echo -e "\033[1;34m$1\033[0m"  # Blue text
}

echo_green() {
  echo -e "\033[1;32m$1\033[0m"  # Green text
}

echo_orange() {
  echo -e "\033[1;33m$1\033[0m"  # Orange text
}

is_messing_dep=false

# Read the dependencies.txt file line by line
while IFS= read -r line; do
	# Parse the line into variables using space as a delimiter
	IFS=$'\t' read -r -a parts <<< "$line"

	[[ "$line" =~ ^[[:space:]]*$ ]] && continue
	
	# Extract the columns
	program=$(echo "${parts[0]}" | sed 's/ *$//')
	plugin="${parts[1]}"
	description="${parts[2]}"

	#echo "$col1"
	
	# Check if the program exists
	if ! is_program_exist "$program"; then
		is_messing_dep=true
		echo 
		echo_red " ($program) - $description"
		echo_red "  - required by $plugin"
	fi

	
done < dependencies.txt

echo 
if $is_messing_dep; then
	echo_orange " install the dependencies listed above"
	exit
fi


# backup old configs
if [ -d "$CONFIG_DISTINATION/nvim" ]; then
	echo -en "\033[1;34mBuckup $CONFIG_DISTINATION/nvim to $CONFIG_DISTINATION/nvim.bak [y/N] :\033[0m "
	read -r REPLY
	case "$REPLY" in
		[yY]) 
			rm -rf $HOME/nvim.bak >/dev/null 2>&1
			mv $HOME/nvim $HOME/nvim.bak >/dev/null 2>&1 
		 ;;
	
	esac
fi

# copy the configs
echo -en "\033[1;34mCopy the configs to $CONFIG_DISTINATION/nvim [y/N] : \033[0m"
read -r REPLY
case "$REPLY" in
	[yY]) 
		cp -r ./nvim $HOME/
		echo_green " Configs installed"
	;;
	
esac

