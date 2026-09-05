#!/usr/bin/env bash
# Per-OS dotfiles installer dispatcher.
#
# Detects the distro and runs the matching per-OS installer:
#   install-omarchy.sh Arch / Omarchy OS: keyd + nvim + tmux configs
#   install-ubuntu.sh   Ubuntu / Debian (apt-based): nvim + tmux configs
#   install-pi.sh       Raspberry Pi OS 64-bit Trixie/aarch64
#   install-macos.sh    macOS: Xcode Command Line Tools + Homebrew
#
# Usage: ./install.sh  (per-OS scripts may prompt for access as needed)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect the operating system. Returns one of:
#   arch | ubuntu | pi | macos | unknown
detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macos"
    return 0
  fi

  local os_release
  local os_id
  local os_codename
  # shellcheck disable=SC1091
  . /etc/os-release
  os_id="${ID:-}"
  os_codename="${VERSION_CODENAME:-}"

  if [[ "$(uname -m)" == "aarch64" ]] &&
    [[ "$os_codename" == "trixie" ]] &&
    [[ "$os_id" == "debian" || "$os_id" == "raspbian" ]]; then
    echo "pi"
    return 0
  fi

  os_release="${os_id} ${ID_LIKE:-}"
  case "$os_release" in
    *arch*) echo "arch" ;;
    *ubuntu* | *debian*) echo "ubuntu" ;;
    *) echo "unknown" ;;
  esac
}

main() {
  local os
  os="$(detect_os)"
  echo "Detected OS: $os"

  case "$os" in
    arch)
      exec "$SCRIPT_DIR/install-omarchy.sh" "$@"
      ;;
    macos)
      exec "$SCRIPT_DIR/install-macos.sh" "$@"
      ;;
    pi)
      exec "$SCRIPT_DIR/install-pi.sh" "$@"
      ;;
    ubuntu)
      exec "$SCRIPT_DIR/install-ubuntu.sh" "$@"
      ;;
    *)
      echo "Error: unsupported OS ($(. /etc/os-release; echo "${ID:-unknown}"))" >&2
      echo "Supported: macOS, Raspberry Pi OS Trixie, arch, ubuntu, debian" >&2
      exit 1
      ;;
  esac
}

# Only run when executed directly (not when sourced, e.g. by tests).
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
