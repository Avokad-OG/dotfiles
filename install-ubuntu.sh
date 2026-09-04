#!/usr/bin/env bash
# Ubuntu / Debian (apt-based) installer: installs the user tools and dotfiles
# used by this repository. No keyd/hypr or other /etc changes are performed.
#
# Idempotent: safe to run repeatedly; existing files are never overwritten.
# Usage: ./install-ubuntu.sh
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DOTFILES_DIR/lib.sh"

# Assign CPU architecture or exit
if ! CPU_ARCHITECTURE="$(cpu_architecture)"; then
  exit 1
fi

main() {
  prepare_sudo
  install_apt_packages \
    build-essential curl git gh unzip fontconfig xz-utils luarocks \
    "liblua${LUA_VERSION}-dev" nodejs npm python3-venv tmux
  install_dotnet
  install_roslyn_language_server
  install_luacheck
  install_nerd_font
  install_npm
  install_nvim
  install_tmux

  link_common_dotfiles
  install_tpm

  upgrade_apt_packages

  setup_bashrc
  setup_starship

  echo
  echo "Done. PATH exports for the .NET SDK, luacheck and nvim were added"
  echo "to ~/.bashrc. Open a new shell (or run: source ~/.bashrc) before using"
  echo "dotnet, roslyn-language-server, luacheck or nvim from the terminal."
  echo "First nvim launch bootstraps lazy.nvim and installs"
  echo "the Mason tools listed in nvim's mason.lua config."
  echo "Client-side: use a Nerd Font in your terminal for LazyVim icons."
  echo "Starship is configured as the bash prompt in ~/.bashrc; it shows in"
  echo "new shells. Pick a style once with e.g.: starship preset pastel-powerline"
}

# Enable the Starship prompt in ~/.bashrc. setup-starship-ubuntu.sh downloads
# the official binary into ~/.local/bin when missing and appends the init line
# idempotently.
setup_starship() {
  local setup="$DOTFILES_DIR/setup-starship-ubuntu.sh"

  if [[ ! -f "$setup" ]]; then
    printf 'Error: starship setup script not found: %s\n' "$setup" >&2
    return 1
  fi

  echo "Configuring Starship in ~/.bashrc..."
  bash "$setup"
}

# Only run when executed directly (not when sourced, e.g. by tests).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
