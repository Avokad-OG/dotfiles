#!/usr/bin/env bash
# Raspberry Pi OS 64-bit (Debian Trixie) installer: installs nvim, tmux,
# unzip and development tools, then symlinks the user dotfiles in this repo.
#
# Idempotent: safe to run repeatedly; existing files are never overwritten.
# Usage: ./install-pi.sh
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DOTFILES_DIR/lib.sh"

CPU_ARCHITECTURE="arm64"

is_raspberry_pi_os() {
  local os_id
  local codename

  [[ "$(uname -m)" == "aarch64" ]] || return 1
  [[ -r /etc/os-release ]] || return 1

  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  codename="${VERSION_CODENAME:-}"

  [[ "$codename" == "trixie" ]] &&
    [[ "$os_id" == "debian" || "$os_id" == "raspbian" ]]
}

main() {
  if ! is_raspberry_pi_os; then
    printf 'Error: install-pi.sh requires Raspberry Pi OS 64-bit (Trixie/aarch64).\n' >&2
    exit 1
  fi

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

  echo
  echo "Done. PATH exports for the .NET SDK, luacheck and nvim were added"
  echo "to ~/.bashrc. Open a new shell (or run: source ~/.bashrc) before using"
  echo "dotnet, roslyn-language-server, luacheck or nvim from the terminal."
  echo "First nvim launch bootstraps lazy.nvim and installs"
  echo "the Mason tools listed in nvim's mason.lua config."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
