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

# Load OS information from /etc/os-release.
if [[ -f /etc/os-release ]]; then
	source /etc/os-release
else
	echo "Cannot determine operating system. /etc/os-release not found."
	exit 1
fi



BASE=("neovim" "git" "curl" "wget" "ranger" "btop" "github-cli" "xsel")
DESKTOP=("bspwm" "sxhkd" "feh" "polybar" "rofi" "dunst" "alacritty")
ARCH_FONTS=("otf-comicshanns-nerd" "ttf-gohu-nerd" "ttf-iosevka-nerd" "ttf-jetbrains-mono-nerd" "ttf-noto-nerd" "noto-fonts-cjk" "noto-fonts-emoji" "noto-fonts-extra" "ttf-victor-mono-nerd")

case "$NAME" in
	"Arch Linux")
		sudo pacman -Syyyu --needed "${BASE[@]}" "${DESKTOP[@]}" "${ARCH_FONTS[@]}"
		;;
	*)
		echo "$NAME is currently unsupported."
		;;
esac

# Set the default editor in the user's bash configuration.
add_line "$HOME/.bashrc" "export EDITOR=nvim"
add_line "$HOME/.bashrc" "alias vim='nvim'"
add_line "$HOME/.bashrc" "alias ivm='nvim'"
add_line "$HOME/.bashrc" "alias vi='nvim'"

source "$HOME/.bashrc"


# Configure git only if the global gitconfig doesn't exist.
if [[ ! -f "$HOME/.gitconfig" ]]; then
	echo "------------- Git config -------------"
	git_username=$(get_user_input "Enter your name: ")
	git_usermail=$(get_user_input "Enter your email: ")
	git config --global user.name "$git_username"
	git config --global user.email "$git_usermail"
fi

