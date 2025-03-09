#!/bin/bash

# default base dir, override with first argument
BASE=${1:-/base}

# find script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/base-env.sh"

# check if base-env.sh exists
if [ ! -f "$SOURCE_FILE" ]; then
	echo "err: base-env.sh not found in $SCRIPT_DIR; please clone the repo again" 
	exit 1
fi

# create $BASE with sudo
if ! sudo mkdir -p "$BASE" 2>/dev/null; then
	echo "err: failed to create $BASE; check permissions or sudo access"
	exit 1
fi
if ! sudo chown "$USER:$USER" "$BASE"; then
	echo "err: failed to chown $BASE; check permissions"
	exit 1
fi

# copy base-env.sh to home dir
if ! cp "$SOURCE_FILE" ~/.base-env.sh; then
	echo "err: failed to copy base-env.sh to ~/.base-evn.sh"
	exit 1
fi

# add to .bashrc if not already present
BASHRC_LINE='if [ -f ~/.base-env.sh ]; then BASE="'"$BASE"'" . ~/.base-env.sh; fi'
if ! grep -Fx "$BASHRC_LINE" ~/.bashrc >/dev/null; then
	echo "$BASHRC_LINE" >> ~/.bashrc
	echo "added sourcing line to ~/.bashrc"
else
	echo "skipped adding sourcing line to ~/.bashrc because it's already present"
fi

echo "done; to apply:"
echo "- restart your terminal, or"
echo "- run 'source ~/.bashrc'"

