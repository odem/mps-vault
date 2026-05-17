#!/bin/sh

# Defaults
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VAULT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)

# Copy plugin
mkdir -p ~/.config/kitty
cp "$VAULT_DIR/plugin/plugin_kitty_vault.py" ~/.config/kitty/
echo "Installed plugin_kitty_vault.py to ~/.config/kitty/"

# Add snippet to .bashrc
SNIPPET="#--- bitwarden -----------------------------------------------------------------
if [[ -n \"\${KITTY_PASSWORD_MANAGER}\" ]]; then
	kitty @ set-colors background='#161666'
	ssh vault \"bw-fzf\"
	pw=\$(ssh vault \"cat /tmp/bw_last ; rm -rf /tmp/bw_last\")
	echo \"\$pw\" | kitty @ send-text -m id:\"\$KITTY_PASSWORD_MANAGER\" --stdin
	exit 0
fi"
if grep -q "KITTY_PASSWORD_MANAGER" ~/.bashrc 2>/dev/null; then
	echo "KITTY_PASSWORD_MANAGER snippet already in ~/.bashrc, skipping."
else
	echo "$SNIPPET" >>~/.bashrc
	echo "Added bitwarden snippet to ~/.bashrc"
fi

# Add keybind to kitty config
KITTY_CONF=~/.config/kitty/kitty.conf
KITTY_MAP="map ctrl+b kitten plugin_kitty_vault.py"
if [ ! -f "$KITTY_CONF" ]; then
	mkdir -p ~/.config/kitty
	echo "$KITTY_MAP" >"$KITTY_CONF"
	echo "Created kitty.conf with password manager keybinding."
elif grep -q "plugin_kitty_vault" "$KITTY_CONF" 2>/dev/null; then
	echo "Keybinding already in kitty.conf, skipping."
else
	echo "$KITTY_MAP" >>"$KITTY_CONF"
	echo "Added keybinding to kitty.conf."
fi

# Start the vault container
docker compose -f "$VAULT_DIR/docker-compose.yml" build && docker compose -f "$VAULT_DIR/docker-compose.yml" up -d
