#!/usr/bin/env bash
# macOS installer: installs Xcode Command Line Tools, the .NET 10 SDK, and
# Homebrew if they are missing, then processes the Brewfile.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DOTFILES_DIR/lib.sh"

xcode_install_interrupted() {
  printf '\nError: user cancelled Xcode Command Line Tools installation.\n' >&2
  exit 130
}

install_xcode() {
  # Homebrew requires Xcode Command Line Tools; full Xcode is not required.
  local label

  if /usr/bin/xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools already installed"
    return 0
  fi

  label="$(/usr/sbin/softwareupdate --list 2>/dev/null |
    sed -n 's/^[[:space:]]*\\* Label: \\(Command Line Tools for Xcode.*\\)$/\\1/p' |
    head -n 1)"

  if [[ -z "$label" ]]; then
    printf 'Error: Xcode Command Line Tools are not available from Apple Software Update.\n' >&2
    return 1
  fi

  echo "Xcode Command Line Tools not found; installing $label..."
  trap xcode_install_interrupted INT TERM
  if ! /usr/sbin/softwareupdate --install "$label"; then
    trap - INT TERM
    printf 'Error: user cancelled or Xcode Command Line Tools installation failed.\n' >&2
    return 1
  fi
  trap - INT TERM

  if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
    printf 'Error: Xcode Command Line Tools installation completed, but they were not found.\n' >&2
    return 1
  fi

  echo "Xcode Command Line Tools installed"
}

brew_path() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  # Homebrew's default locations on Apple Silicon and Intel Macs.
  for path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$path" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
  done

  return 1
}

install_homebrew() {
  local brew
  local installer

  if brew="$(brew_path)"; then
    echo "Homebrew already installed: $brew"
    echo "Updating Homebrew..."
    "$brew" update
    echo "Upgrading Homebrew packages..."
    "$brew" upgrade
    return 0
  fi

  echo "Homebrew not found; installing..."
  installer="$(curl -fsSL "$HOMEBREW_INSTALLER_URL")"
  /bin/bash -c "$installer"

  if ! brew="$(brew_path)"; then
    printf 'Error: Homebrew installation completed, but brew was not found.\n' >&2
    exit 1
  fi

  echo "Homebrew installed: $brew"
}

install_brewfile() {
  local brew

  if ! brew="$(brew_path)"; then
    printf 'Error: brew was not found; cannot process Brewfile.\n' >&2
    exit 1
  fi

  if [[ ! -f "$DOTFILES_DIR/Brewfile" ]]; then
    printf 'Error: Brewfile not found: %s\n' "$DOTFILES_DIR/Brewfile" >&2
    exit 1
  fi

  echo "Installing Homebrew dependencies from Brewfile..."
  "$brew" bundle --file="$DOTFILES_DIR/Brewfile"
}

main() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'Error: install-macos.sh must be run on macOS.\n' >&2
    exit 1
  fi

  install_xcode
  install_dotnet
  install_roslyn_language_server
  install_homebrew
  install_brewfile
  link_common_dotfiles
  # kitty is macOS-only here (Brewfile cask), so it is not part of the
  # shared link_common_dotfiles step.
  link "$DOTFILES_DIR/.config/kitty" "$HOME/.config/kitty"
  install_tpm

  # Add future macOS installations here.
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
