#!/usr/bin/env bash
# Add the .NET SDK to PATH in ~/.zshrc.
#
# The SDK installs to "$HOME/.dotnet" with --no-path, so `dotnet` is not on
# PATH. This script appends the standard .NET PATH lines to ~/.zshrc and
# verifies dotnet is reachable in a fresh interactive zsh.
#
# Idempotent: safe to run multiple times; existing ~/.zshrc is preserved.
set -euo pipefail

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
DOTNET_DIR="${DOTNET_DIR:-$HOME/.dotnet}"

# --- Required files -----------------------------------------------------------
if [[ ! -x "$DOTNET_DIR/dotnet" ]]; then
  echo "Error: .NET SDK not found at $DOTNET_DIR/dotnet." >&2
  echo "       The SDK should already be installed here. Re-run your dotfiles" >&2
  echo "       installer (it installs the SDK before this PATH setup step), or" >&2
  echo "       install it manually to that exact directory first." >&2
  exit 1
fi
echo "Found .NET SDK at $DOTNET_DIR/dotnet: $("$DOTNET_DIR/dotnet" --version)"

# --- Lines to add to ~/.zshrc ---------------------------------------------------
# Global .NET tools (e.g. roslyn-language-server) install to ~/.dotnet/tools,
# so both the SDK dir and the tools dir go on PATH.
readonly BLOCK=(
  '# .NET SDK (dotnet-install.sh) -- added by setup-dotnet.sh'
  "export DOTNET_ROOT=\"$DOTNET_DIR\""
  "export PATH=\"\$PATH:$DOTNET_DIR\""
  "export PATH=\"\$PATH:$HOME/.dotnet/tools\""
)

if [[ ! -f "$ZSHRC" ]]; then
  : > "$ZSHRC"  # create it
  echo "Created $ZSHRC (did not exist)"
fi

added=0
for line in "${BLOCK[@]}"; do
  if ! grep -qxF -- "$line" "$ZSHRC"; then
    printf '%s\n' "$line" >> "$ZSHRC"
    added=1
  fi
done

if (( added )); then
  echo "Added .NET configuration to $ZSHRC"
else
  echo ".NET already configured in $ZSHRC; skipping."
  exit 0
fi

# --- Verify dotnet is on PATH in a fresh interactive zsh --------------------------
if zsh -ic 'command -v dotnet' 2>/dev/null | grep -q "$DOTNET_DIR/dotnet"; then
  echo "OK: dotnet is on PATH ($DOTNET_DIR/dotnet)"
else
  echo "Warning: dotnet did not load. Check $ZSHRC for errors." >&2
  exit 1
fi

echo
echo "Done! dotnet is configured for new zsh sessions."
echo "  1. Open a new terminal window (or run: source $ZSHRC)"
echo "  2. Try: dotnet --version"
