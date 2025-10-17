#!/usr/bin/env bash
# Simple installer for Sherman
set -euo pipefail

REPO_DIR="$(pwd)"
TARGET="$HOME/.local/bin/sherman"

echo "Installing Sherman from $REPO_DIR to $TARGET"
install -Dm755 "$REPO_DIR/sherman.sh" "$TARGET"

# Ensure ~/.local/bin is in PATH via ~/.bashrc
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  echo "Added ~/.local/bin to PATH in ~/.bashrc"
fi

echo "Installed to $TARGET"
# Run help in a new shell so the updated PATH is picked up
exec bash -lc 'sherman --help'
