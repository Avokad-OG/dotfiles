#!/usr/bin/env bash
# Omarchy installer: links the user dotfiles, installs keyd + luacheck, and
# ensures Node.js and the .NET SDK are available via mise (Omarchy's runtime
# manager). Omarchy preinstalls Node.js (via mise), luarocks, nvim, tmux,
# git, ...; this script only adds what Omarchy does not ship. Idempotent: safe
# to re-run.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib.sh
source "$DOTFILES_DIR/lib.sh"

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Error: install-omarchy.sh is Omarchy-only; the omarchy CLI was not found.\n' >&2
  exit 1
fi

install_node() {
  if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "ok:     node/npm already installed ($(node --version), $(npm --version))"
    return 0
  fi

  if ! command -v mise >/dev/null 2>&1; then
    printf 'Error: mise is required to install Node.js on Omarchy.\n' >&2
    return 1
  fi

  # Same setup Omarchy runs at first boot (install/user/mise-work.sh):
  # installs the latest Node and makes it the global default.
  if mise which node >/dev/null 2>&1; then
    echo "ok:     node/npm provided by mise ($(mise which node))"
    return 0
  fi

  echo "node/npm: not installed, installing via mise..."
  run_quietly mise use -g node@latest

  if ! mise which node >/dev/null 2>&1; then
    printf 'Error: node did not install via mise.\n' >&2
    return 1
  fi

  echo "node/npm: installed via mise ($(mise which node))"
}

install_dotnet() {
  local dotnet

  # Accept an existing .NET only if it actually has an SDK (Omarchy ships a
  # dotnet-runtime package that provides no SDK).
  if command -v dotnet >/dev/null 2>&1 &&
    dotnet --list-sdks 2>/dev/null | grep -q .; then
    echo "ok:     dotnet SDK already installed ($(dotnet --version))"
    return 0
  fi

  if ! command -v mise >/dev/null 2>&1; then
    printf 'Error: mise is required to install .NET on Omarchy.\n' >&2
    return 1
  fi

  if dotnet="$(mise which dotnet 2>/dev/null)" &&
    "$dotnet" --list-sdks 2>/dev/null | grep -q .; then
    echo "ok:     dotnet SDK provided by mise ($dotnet)"
    return 0
  fi

  # Same setup Omarchy offers via `omarchy install dev-env dotnet`.
  echo "dotnet:  not installed, installing via mise..."
  run_quietly mise use -g dotnet@latest

  if ! dotnet="$(mise which dotnet 2>/dev/null)" ||
    ! "$dotnet" --list-sdks 2>/dev/null | grep -q .; then
    printf 'Error: dotnet did not install via mise.\n' >&2
    return 1
  fi

  echo "dotnet:  installed via mise ($dotnet)"
}

# Omarchy variant of lib.sh's install_roslyn_language_server: resolves dotnet
# via mise instead of ~/.dotnet (global tools still land in ~/.dotnet/tools).
install_roslyn_language_server() {
  local dotnet

  if [[ -x "$HOME/.dotnet/tools/roslyn-language-server" ]]; then
    echo "ok:     roslyn language server already installed"
    return 0
  fi

  # Prefer the mise-managed SDK over a system dotnet (which on Omarchy may be
  # the runtime-only dotnet-runtime package).
  dotnet="$(mise which dotnet 2>/dev/null || true)"
  if [[ -z "$dotnet" ]]; then
    dotnet="$(command -v dotnet 2>/dev/null || true)"
  fi
  if [[ -z "$dotnet" ]]; then
    printf 'Error: dotnet is required to install Roslyn.\n' >&2
    return 1
  fi

  echo "Roslyn language server not found; installing globally..."
  run_quietly "$dotnet" tool install --global roslyn-language-server --prerelease

  if [[ ! -x "$HOME/.dotnet/tools/roslyn-language-server" ]]; then
    printf 'Error: Roslyn installation completed, but the executable was not found.\n' >&2
    return 1
  fi

  echo "Roslyn language server installed: $HOME/.dotnet/tools/roslyn-language-server"
}

install_keyd() {
  if command -v keyd >/dev/null 2>&1 &&
    pacman -Q keyd >/dev/null 2>&1; then
    echo "ok:     keyd already installed"
    return 0
  fi

  echo "keyd:   installing..."
  run_quietly omarchy pkg add keyd

  if ! command -v keyd >/dev/null 2>&1 ||
    ! pacman -Q keyd >/dev/null 2>&1; then
    printf 'Error: keyd did not install.\n' >&2
    exit 1
  fi

  echo "keyd:   installed"
}

configure_keyd() {
  local config_file="$DOTFILES_DIR/etc/keyd/default.conf"

  if [[ ! -f "$config_file" ]]; then
    printf 'Error: keyd config not found: %s\n' "$config_file" >&2
    exit 1
  fi

  # Link the config before starting keyd.
  link_system "$config_file" "/etc/keyd/default.conf"

  echo "keyd:   enabling service..."
  run_quietly "${SUDO[@]}" systemctl enable --now keyd.service

  echo "keyd:   reloading configuration..."
  run_quietly "${SUDO[@]}" keyd reload

  echo "keyd:   configured and running"
}

main() {
  prepare_sudo

  install_node
  install_dotnet
  install_roslyn_language_server
  link_common_dotfiles
  link "$DOTFILES_DIR/.config/hypr" \
    "$HOME/.config/hypr"
  link "$DOTFILES_DIR/.config/kitty" \
    "$HOME/.config/kitty"
  install_tpm
  install_luacheck

  install_keyd
  configure_keyd

  echo
  echo "Done. First nvim launch bootstraps lazy.nvim and installs"
  echo "the Mason tools listed in nvim's mason.lua config."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
