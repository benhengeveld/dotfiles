#!/usr/bin/env bash
set -e

ask_yes_no() {
	while true; do
		read -rp "$1 (y/n): " response
		case "$response" in
			y|Y) return 0 ;;
			n|N) return 1 ;;
		esac
	done
}

if ! command -v code >/dev/null 2>&1; then
	echo "VS Code CLI ('code') not found. Install VS Code and enable 'code' in PATH."
	exit 1
fi

BASE_RAW="https://raw.githubusercontent.com/benhengeveld/dotfiles/main/vscode"

EXTENSIONS_URL="$BASE_RAW/extensions.txt"
SETTINGS_URL="$BASE_RAW/settings.json"
KEYBINDINGS_URL="$BASE_RAW/keybindings.json"

VSCODE_USER_DIR="$HOME/.config/Code/User"

mkdir -p "$VSCODE_USER_DIR"

if ask_yes_no "Install VS Code extensions?"; then
	if ! curl -fsSL "$EXTENSIONS_URL" | \
	while read -r line; do
		[[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
		echo "Installing extension: $line"
		code --install-extension "$line" || true
	done; then
		echo "Error: Failed to download extensions list"
		exit 1
	fi
else
	echo "Skipped extension installation"
fi

if ask_yes_no "Update settings.json? (this will overwrite existing)"; then
	# Backup if exists
	if [[ -f "$VSCODE_USER_DIR/settings.json" ]]; then
		cp "$VSCODE_USER_DIR/settings.json" "$VSCODE_USER_DIR/settings.json.backup"
	fi

	echo "Updating settings.json"
	if ! curl -fsSL "$SETTINGS_URL" -o "$VSCODE_USER_DIR/settings.json"; then
		echo "Error: Failed to download settings.json"
		# Restore backup if download failed
		if [[ -f "$VSCODE_USER_DIR/settings.json.backup" ]]; then
			mv "$VSCODE_USER_DIR/settings.json.backup" "$VSCODE_USER_DIR/settings.json"
			echo "Restored backup"
		fi
		exit 1
	fi

	# Validate downloaded file
	if [[ ! -s "$VSCODE_USER_DIR/settings.json" ]]; then
		echo "Warning: Downloaded settings.json is empty"
		# Restore backup
		if [[ -f "$VSCODE_USER_DIR/settings.json.backup" ]]; then
			mv "$VSCODE_USER_DIR/settings.json.backup" "$VSCODE_USER_DIR/settings.json"
			echo "Restored backup"
		fi
		exit 1
	fi

	# Delete backup after successful replacement
	rm -f "$VSCODE_USER_DIR/settings.json.backup"
else
	echo "Skipped settings.json"
fi

if ask_yes_no "Update keybindings.json? (this will overwrite existing)"; then
	# Backup if exists
	if [[ -f "$VSCODE_USER_DIR/keybindings.json" ]]; then
		cp "$VSCODE_USER_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json.backup"
	fi

	echo "Updating keybindings.json"
	if ! curl -fsSL "$KEYBINDINGS_URL" -o "$VSCODE_USER_DIR/keybindings.json"; then
		echo "Error: Failed to download keybindings.json"
		# Restore backup if download failed
		if [[ -f "$VSCODE_USER_DIR/keybindings.json.backup" ]]; then
			mv "$VSCODE_USER_DIR/keybindings.json.backup" "$VSCODE_USER_DIR/keybindings.json"
			echo "Restored backup"
		fi
		exit 1
	fi

	# Validate downloaded file
	if [[ ! -s "$VSCODE_USER_DIR/keybindings.json" ]]; then
		echo "Warning: Downloaded keybindings.json is empty"
		# Restore backup
		if [[ -f "$VSCODE_USER_DIR/keybindings.json.backup" ]]; then
			mv "$VSCODE_USER_DIR/keybindings.json.backup" "$VSCODE_USER_DIR/keybindings.json"
			echo "Restored backup"
		fi
		exit 1
	fi

	# Delete backup after successful replacement
	rm -f "$VSCODE_USER_DIR/keybindings.json.backup"
else
	echo "Skipped keybindings.json"
fi

echo
echo "VS Code setup complete"
echo "You may need to reload or restart VS Code for all changes to take effect."
