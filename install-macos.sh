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
  local waited

  if /usr/bin/xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools already installed"
    return 0
  fi

  # Preferred on older macOS: Apple offers CLT through Software Update, either
  # as a fresh install or an upgrade. Current macOS versions only list CLT there
  # when one is already installed but outdated, so this usually finds nothing on
  # a fresh machine and we fall through to xcode-select below.
  label="$(/usr/sbin/softwareupdate --list 2>/dev/null |
    sed -n 's/^[[:space:]]*\* Label: \(Command Line Tools for Xcode.*\)$/\1/p' |
    head -n 1)"

  trap xcode_install_interrupted INT TERM
  if [[ -n "$label" ]]; then
    echo "Xcode Command Line Tools not found; installing $label..."
    if ! /usr/sbin/softwareupdate --install --agree-to-license "$label"; then
      trap - INT TERM
      printf 'Error: user cancelled or Xcode Command Line Tools installation failed.\n' >&2
      return 1
    fi
  else
    # Fresh installs are not offered through Software Update: Apple gates them
    # behind an "install on demand" marker that only xcode-select --install
    # creates. That command shows Apple's installer dialog and downloads in the
    # background, so request it and poll until the tools are in place. If an
    # installation is already in progress, requesting again fails; ignore that
    # and keep waiting.
    echo "Xcode Command Line Tools not found; requesting installation..."
    /usr/bin/xcode-select --install 2>/dev/null || true

    waited=0
    until /usr/bin/xcode-select -p >/dev/null 2>&1; do
      if (( waited >= 600 )); then # 10 minutes
        trap - INT TERM
        printf 'Error: timed out waiting for the Xcode Command Line Tools installation.\n' >&2
        printf 'Click Install in the dialog if it is still open, or re-run this installer.\n' >&2
        return 1
      fi
      sleep 5
      waited=$((waited + 5))
    done
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

# Wire the brew-installed Powerlevel10k into ~/.zshrc so the p10k prompt and
# `p10k configure` work. Must run after install_brewfile, which installs the
# powerlevel10k / zsh-autosuggestions / zsh-syntax-highlighting packages this
# depends on. The setup script is invoked through bash (not executed directly)
# so it also works if Gatekeeper quarantined a ZIP-downloaded repo.
setup_p10k() {
  local setup="$DOTFILES_DIR/setup-p10k-macos.sh"

  if [[ ! -f "$setup" ]]; then
    printf 'Error: p10k setup script not found: %s\n' "$setup" >&2
    return 1
  fi

  echo "Configuring Powerlevel10k in ~/.zshrc..."
  bash "$setup"
}

# Add the .NET SDK (installed by install_dotnet to ~/.dotnet with --no-path)
# to PATH in ~/.zshrc. Must run after install_dotnet, which the setup script
# verifies; run after setup_p10k so p10k's instant-prompt block stays at the
# top of ~/.zshrc. Invoked through bash for the same Gatekeeper reason as
# setup_p10k.
setup_dotnet() {
  local setup="$DOTFILES_DIR/setup-dotnet-macos.sh"

  if [[ ! -f "$setup" ]]; then
    printf 'Error: dotnet setup script not found: %s\n' "$setup" >&2
    return 1
  fi

  echo "Adding .NET SDK to PATH in ~/.zshrc..."
  bash "$setup"
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
  setup_p10k
  setup_dotnet
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
