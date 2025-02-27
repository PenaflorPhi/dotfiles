#!/bin/bash
set -euo pipefail


# Function to add a line to a file if it does not already exist.
add_line() {
	local file="$1"
	local line="$2"

	if [[ ! -f "$file" ]]; then
		touch "$file"
	fi

	if ! grep -Fxq "$line" "$file"; then
		echo "$line" >> "$file"
	fi
	echo "Added: $line to $file"
}

# Prompt the user for input.
get_user_input() {
	local prompt="$1"
	local user_input

	read -rp "$prompt" user_input
	echo "$user_input"
}

# Ensure a directory exists, creating it if necessary.
ensure_dir() {
	local dir="$1"
	if [[ ! -d "$dir" ]]; then
		echo "Creating directory: $dir"
		mkdir -pv "$dir"
	fi
}

# Stow configuration directories.
stow_dir() {
	local target_dir="$1"
	local source_dir="$2"

	ensure_dir "$target_dir"
	echo "Stowing $source_dir into $target_dir"
	stow --adopt -t "$target_dir" "$source_dir"
}

# Load OS information.
if [[ -f /etc/os-release ]]; then
	source /etc/os-release
else
	echo "Cannot determine OS. Exiting."
	exit 1
fi

# Get correct path
DIR="$(dirname "$(realpath "$0")")"
cd "$DIR"


# Define package lists.
BASE=("neovim" "git" "curl" "wget" "ranger" "btop" "github-cli" "xsel" "stow" "less" "tar" "ripgrep")
DESKTOP=("bspwm" "sxhkd" "feh" "polybar" "rofi" "dunst" "alacritty")

# Detect OS and install packages.
case "$NAME" in
	"Arch Linux")
		echo "Detected Arch Linux. Installing packages..."
		DEV=("clang" "python" "rust" "lua" "luarocks" "npm" "go" "dotnet-host" "dotnet-runtime")
		ARCH_FONTS=("otf-comicshanns-nerd" "ttf-gohu-nerd" "ttf-iosevka-nerd" "ttf-jetbrains-mono-nerd" "ttf-noto-nerd" "noto-fonts-cjk" "noto-fonts-emoji" "noto-fonts-extra" "ttf-victor-mono-nerd")
        RANGER=("transmission-cli", "unrar")
		sudo pacman -Syyyu --needed "${BASE[@]}" "${DESKTOP[@]}" "${ARCH_FONTS[@]}" "${DEV[@]}" "${RANGER[@]}"

	# Install paru if missing.
	if ! pacman -Q paru &>/dev/null; then
		echo "Installing paru (AUR helper)..."
		git clone https://aur.archlinux.org/paru.git
		cd paru
		makepkg -sic
		cd ..
		rm -rf paru
	fi
	;;
*)
	echo "Unsupported OS: $NAME"
	exit 1
	;;
esac

# Configure shell environment.
BASHRC="$HOME/.bashrc"
echo "Configuring shell environment..."
add_line "$BASHRC" "export EDITOR=nvim"
add_line "$BASHRC" 'export PATH="$HOME/.local/bin:$PATH"'
add_line "$BASHRC" "alias vim='nvim'"
add_line "$BASHRC" "alias ivm='nvim'"
add_line "$BASHRC" "alias vi='nvim'"

# Configure Git.
if [[ ! -f "$HOME/.gitconfig" ]]; then
	echo "Configuring Git..."
	git_username=$(get_user_input "Enter your name: ")
	git_usermail=$(get_user_input "Enter your email: ")
	git config --global user.name "$git_username"
	git config --global user.email "$git_usermail"
    git config --global init.defaultBranch main
fi

# Stow configuration files.
echo "Stowing configurations..."
stow_dir "$HOME/.config" config
stow_dir "$HOME/Pictures" pictures
stow_dir "$HOME/.local/bin" bin
stow_dir "$HOME/" home

echo "Setup complete!"
