#!/bin/bash
set -euo pipefail

# Add a line to a file if it does not already exist.
add_line() {
	local file="$1"
	local line="$2"

    # Ensure the file exists
    if [[ ! -f "$file" ]]; then
	    touch "$file"
    fi

    if ! grep -Fxq "$line" "$file"; then
	    echo "$line" >> "$file"
    fi
    echo "$line"
}

# Prompt the user for input and return the entered value.
get_user_input() {
	local prompt="$1"
	local user_input

	read -rp "$prompt" user_input
	echo "$user_input"
}

# Ensure that a directory exists; if not, create it.
ensure_dir() {
	local dir="$1"
	if [[ ! -d "$dir" ]]; then
		mkdir -pv "$dir"
	fi
}

# If the target directory exists, back it up before creating a symlink.
move_dir() {
	local src_dir="$1"
	local dest_dir="$2"

    # Create destination directory if it doesn't exist
    mkdir -pv "$dest_dir"

    # Loop over each item in the source directory
    for item in "$src_dir"/*; do
	    # Skip if no items exist in source directory
	    [[ -e "$item" ]] || continue

	    local item_name
	    item_name=$(basename "$item")
	    local dest_item="$dest_dir/$item_name"
	    echo "DESTINATION $dest_item"

	# If destination item exists, back it up by renaming it
	if [[ -e "$dest_item" ]]; then
		mv -v "$dest_item" "${dest_item}.old"
	fi

	# Move the item to the destination
	mv -v "$item" "$dest_dir"
done
}

# Load OS information from /etc/os-release.
if [[ -f /etc/os-release ]]; then
	source /etc/os-release
else
	echo "Cannot determine operating system. /etc/os-release not found."
	exit 1
fi

utilities=("neovim" "git" "curl" "wget" "ranger" "btop" "github-cli")
desktop=("bspwm" "sxhkd" "feh" "polybar" "rofi" "dunst" "alacritty")

case "$NAME" in
	"Arch Linux")
		sudo pacman -Syyyu --needed "${utilities[@]}" "${desktop[@]}"
		;;
	*)
		echo "$NAME is currently unsupported."
		;;
esac

# Set the default editor in the user's bash configuration.
add_line "$HOME/.bashrc" "export EDITOR=nvim"

# Configure git only if the global gitconfig doesn't exist.
if [[ ! -f "$HOME/.gitconfig" ]]; then
	echo "------------- Git config -------------"
	git_username=$(get_user_input "Enter your name: ")
	git_usermail=$(get_user_input "Enter your email: ")
	git config --global user.name "$git_username"
	git config --global user.email "$git_usermail"
fi



move_dir "config" "$HOME/.config"
move_dir "pictures" "$HOME/Pictures"
