#!/usr/bin/env bash
# Shared helpers for all per-OS installer scripts.
#
# The caller must set DOTFILES_DIR before sourcing this file. Debian-based
# helpers additionally expect CPU_ARCHITECTURE to be set to x86_64 or arm64.
# Never overwrites existing paths; safe to re-run.

SUDO=()
DOTNET_DIR="${DOTNET_DIR:-$HOME/.dotnet}"
DOTNET_VERSION="${DOTNET_VERSION:-10.0.400}"
LUA_VERSION="${LUA_VERSION:-5.4}"
LUA_ROCKS_BIN="${LUA_ROCKS_BIN:-$HOME/.luarocks/bin}"
NEOVIM_VERSION="${NEOVIM_VERSION:-0.12.5}"
NEOVIM_INSTALL_ROOT="${NEOVIM_INSTALL_ROOT:-/opt}"
NERD_FONT_URL="${NERD_FONT_URL:-https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz}"
DOTNET_INSTALLER_URL="${DOTNET_INSTALLER_URL:-https://dot.net/v1/dotnet-install.sh}"
HOMEBREW_INSTALLER_URL="${HOMEBREW_INSTALLER_URL:-https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh}"
TPM_REPOSITORY="${TPM_REPOSITORY:-https://github.com/tmux-plugins/tpm}"

# Link $src into $dst if $dst is absent. Never overwrites existing paths:
#   - $dst already a symlink to $src            -> ok
#   - $dst a symlink to something else          -> skip (reported)
#   - $dst exists as a real file/dir            -> skip (reported)
link() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    printf 'Error: link source does not exist: %s\n' "$src" >&2
    return 1
  fi

  if [[ -L "$dst" ]]; then
    local target
    target="$(readlink "$dst")"
    if [[ "$target" == "$src" ]]; then
      echo "ok:     $dst already linked to repo"
    else
      echo "skip:   $dst symlinks to $target (not the repo)"
    fi
    return 0
  fi

  if [[ -e "$dst" ]]; then
    echo "skip:   $dst exists and is not a symlink; repo config not applied"
    return 0
  fi

  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

# Link a root-owned path using the caller's prepared sudo command.
link_system() {
  local src="$1"
  local dst="$2"
  local target

  if [[ ! -e "$src" ]]; then
    printf 'Error: link source does not exist: %s\n' "$src" >&2
    return 1
  fi

  if "${SUDO[@]}" test -L "$dst"; then
    target="$("${SUDO[@]}" readlink "$dst")"
    if [[ "$target" == "$src" ]]; then
      echo "ok:     $dst already linked to repo"
    else
      echo "skip:   $dst symlinks to $target (not the repo)"
    fi
    return 0
  fi

  if "${SUDO[@]}" test -e "$dst"; then
    echo "skip:   $dst exists and is not a symlink; repo config not applied"
    return 0
  fi

  "${SUDO[@]}" mkdir -p "$(dirname "$dst")"
  "${SUDO[@]}" ln -s "$src" "$dst"
  echo "linked: $dst -> $src (via sudo)"
}

# Prepare the optional sudo command used by Linux installers. macOS does not
# call this function because its installers handle privileges independently.
prepare_sudo() {
  SUDO=()

  if [[ $EUID -eq 0 ]]; then
    return 0
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    printf 'Error: sudo is not installed.\n' >&2
    return 1
  fi

  printf 'Requesting administrator access...\n'
  if ! sudo -v; then
    printf 'Error: sudo authentication failed.\n' >&2
    return 1
  fi

  SUDO=(sudo)
}

# Link the dotfiles shared by all user-level installers. .gitignore is not
# linked because it is repository metadata, not a user configuration file.
link_common_dotfiles() {
  link "$DOTFILES_DIR/.markdownlint-cli2.jsonc" \
    "$HOME/.markdownlint-cli2.jsonc"
  link "$DOTFILES_DIR/.prettierrc.json" \
    "$HOME/.prettierrc.json"
  link "$DOTFILES_DIR/.config/nvim" \
    "$HOME/.config/nvim"
  link "$DOTFILES_DIR/.config/tmux" \
    "$HOME/.config/tmux"
}

# Return CPU architecture in the naming convention used by Neovim releases.
cpu_architecture() {
  local raw_arch
  raw_arch="$(uname -m)" || return 1

  case "$raw_arch" in
  x86_64 | amd64)
    printf 'Running on x86_64\n' >&2
    printf '%s\n' "x86_64"
    ;;
  arm64 | aarch64)
    printf 'Running on arm64\n' >&2
    printf '%s\n' "arm64"
    ;;
  *)
    printf 'Unsupported architecture: %s\n' "$raw_arch" >&2
    return 1
    ;;
  esac
}

# Debian/Ubuntu helpers. Apt itself is idempotent, but to avoid re-running
# apt-get update/install on repeat runs, only attempt the packages that are
# actually missing and skip upgrades when none are pending.
install_apt_packages() {
  local pkg
  local -a to_install

  for pkg in "$@"; do
    if dpkg-query -W -f='${db:Status-Abbrev}' "$pkg" 2>/dev/null | grep -q '^ii'; then
      echo "ok:     $pkg already installed"
    else
      to_install+=("$pkg")
    fi
  done

  if (( ${#to_install[@]} == 0 )); then
    echo "All apt packages already installed; skipping apt install."
    return 0
  fi

  echo "Installing apt packages: ${to_install[*]}"
  run_quietly "${SUDO[@]}" apt-get update
  run_quietly "${SUDO[@]}" apt-get install -y "${to_install[@]}"
}

upgrade_apt_packages() {
  if ! apt-get -s upgrade 2>&1 | grep -q '^Inst'; then
    echo "No apt upgrades available; skipping upgrade."
    return 0
  fi
  echo "Upgrading apt packages..."
  run_quietly "${SUDO[@]}" apt-get upgrade -y
}

nvim_bin() {
  local architecture="${CPU_ARCHITECTURE:-}"

  if command -v nvim >/dev/null 2>&1; then
    command -v nvim
  elif [[ -n "$architecture" &&
    -x "$NEOVIM_INSTALL_ROOT/nvim-linux-${architecture}/bin/nvim" ]]; then
    printf '%s\n' "$NEOVIM_INSTALL_ROOT/nvim-linux-${architecture}/bin/nvim"
  else
    return 1
  fi
}

nvim_present() {
  nvim_bin >/dev/null 2>&1
}

tmux_present() {
  command -v tmux >/dev/null 2>&1
}

install_nerd_font() {
  # Same font as macOS (Brewfile: font-meslo-lg-nerd-font cask).
  local font_family="MesloLGM Nerd Font"
  local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/MesloLGMNerdFont"
  local tmp_file

  if command -v fc-list >/dev/null 2>&1 &&
    fc-list : family | grep -Fqi "$font_family"; then
    echo "$font_family is already installed."
    return 0
  fi

  if [[ -n "$(find "$font_dir" -type f \( -name '*.ttf' -o -name '*.otf' \) \
    -print -quit 2>/dev/null)" ]]; then
    echo "Font files already exist in $font_dir."
    run_quietly fc-cache -f "$font_dir"
    return 0
  fi

  echo "Installing $font_family..."
  tmp_file="$(mktemp)"

  if ! run_quietly curl -fL \
    "$NERD_FONT_URL" \
    -o "$tmp_file"; then
    rm -f "$tmp_file"
    return 1
  fi

  if ! run_quietly mkdir -p "$font_dir" ||
    ! run_quietly tar -xJf "$tmp_file" -C "$font_dir"; then
    rm -f "$tmp_file"
    return 1
  fi

  rm -f "$tmp_file"
  run_quietly fc-cache -f
  echo "$font_family installed successfully."
}

install_nvim() {
  local tmp_file
  local architecture="${CPU_ARCHITECTURE:?CPU_ARCHITECTURE is not set}"

  if nvim_present; then
    echo "ok:     nvim already installed ($(nvim_bin))"
    return 0
  fi

  echo "nvim:   not installed, installing..."
  tmp_file="$(mktemp)"

  if ! run_quietly curl -fL \
    -o "$tmp_file" \
    "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${architecture}.tar.gz"; then
    rm -f "$tmp_file"
    return 1
  fi

  if ! run_quietly "${SUDO[@]}" rm -rf \
    "$NEOVIM_INSTALL_ROOT/nvim-linux-${architecture}" ||
    ! run_quietly "${SUDO[@]}" tar -C "$NEOVIM_INSTALL_ROOT" -xzf "$tmp_file"; then
    rm -f "$tmp_file"
    return 1
  fi

  rm -f "$tmp_file"

  if ! nvim_present; then
    printf 'Error: neovim did not install.\n' >&2
    return 1
  fi

  echo "nvim:   installed ($(nvim_bin))"
}

install_tmux() {
  if tmux_present; then
    echo "ok:     tmux already installed ($(command -v tmux))"
    return 0
  fi

  echo "tmux:   not installed, installing..."
  install_apt_packages tmux

  if ! tmux_present; then
    printf 'Error: tmux did not install.\n' >&2
    return 1
  fi

  echo "tmux:   installed ($(command -v tmux))"
}

# Add the per-user PATH exports the Linux installers produce to ~/.bashrc:
#   - the .NET SDK (installed with --no-path to $DOTNET_DIR) and its global
#     tools directory (roslyn-language-server lives in ~/.dotnet/tools)
#   - luacheck, installed with `luarocks --local` to $LUA_ROCKS_BIN
#   - the Neovim release tarball at $NEOVIM_INSTALL_ROOT/nvim-linux-$CPU_ARCHITECTURE/bin
# Idempotent: each missing line is appended once; existing lines are preserved.
setup_bashrc() {
  local bashrc="$HOME/.bashrc"
  local nvim_bin="${NEOVIM_INSTALL_ROOT}/nvim-linux-${CPU_ARCHITECTURE}/bin"
  local line
  local added=0
  local -a lines

  lines=(
    '# dotfiles installer: .NET SDK, luacheck, nvim PATH'
    "export DOTNET_ROOT=\"$DOTNET_DIR\""
    "export PATH=\"\$PATH:$DOTNET_DIR\""
    "export PATH=\"\$PATH:$HOME/.dotnet/tools\""
    "export PATH=\"\$PATH:$LUA_ROCKS_BIN\""
    "export PATH=\"\$PATH:$nvim_bin\""
  )

  if [[ ! -f "$bashrc" ]]; then
    : >"$bashrc"
    echo "Created $bashrc (did not exist)"
  fi

  for line in "${lines[@]}"; do
    if ! grep -qxF -- "$line" "$bashrc"; then
      printf '%s\n' "$line" >>"$bashrc"
      added=1
    fi
  done

  if ((added)); then
    echo "Added PATH exports to $bashrc"
  else
    echo "$bashrc already configured; no changes made"
  fi
}

install_npm() {
  if command -v npm >/dev/null 2>&1; then
    echo "ok:     npm already installed ($(npm --version))"
    return 0
  fi

  echo "npm:    not installed, installing..."
  install_apt_packages nodejs npm
  echo "npm:    installed ($(npm --version))"
}

install_luacheck() {
  if [[ -x "$LUA_ROCKS_BIN/luacheck" ]]; then
    echo "ok:     luacheck already installed ($LUA_ROCKS_BIN/luacheck)"
    return 0
  fi

  if ! command -v luarocks >/dev/null 2>&1; then
    printf 'Error: luarocks is required to install luacheck.\n' >&2
    return 1
  fi

  echo "luacheck: not installed, installing for Lua ${LUA_VERSION}..."
  luarocks --lua-version="$LUA_VERSION" --local install luacheck

  if [[ ! -x "$LUA_ROCKS_BIN/luacheck" ]]; then
    printf 'Error: luacheck did not install to %s.\n' "$LUA_ROCKS_BIN" >&2
    return 1
  fi

  echo "luacheck: installed ($LUA_ROCKS_BIN/luacheck)"
}

# Install the .NET 10 SDK with Microsoft's official installer. The installer
# supports macOS and Linux, including x64 and arm64/aarch64 systems.
dotnet_sdk_10_installed() {
  [[ -x "$DOTNET_DIR/dotnet" ]] &&
    "$DOTNET_DIR/dotnet" --list-sdks 2>/dev/null |
    grep -Fq "${DOTNET_VERSION} ["
}

install_dotnet() {
  if dotnet_sdk_10_installed; then
    echo ".NET 10 SDK already installed: $DOTNET_DIR"
    return 0
  fi

  echo ".NET 10 SDK not found; installing from Microsoft..."
  if ! curl -fsSL "$DOTNET_INSTALLER_URL" |
    /bin/bash -s -- \
      --install-dir "$DOTNET_DIR" \
      --version "$DOTNET_VERSION" \
      --no-path; then
    printf 'Error: .NET 10 SDK installation failed.\n' >&2
    return 1
  fi

  if ! dotnet_sdk_10_installed; then
    printf 'Error: .NET 10 SDK installation completed, but it was not found.\n' >&2
    return 1
  fi

  echo ".NET 10 SDK installed: $DOTNET_DIR"
}

roslyn_language_server_installed() {
  [[ -x "$HOME/.dotnet/tools/roslyn-language-server" ]]
}

# Install Roslyn as a per-user global .NET tool. It is installed separately
# from Mason because the Neovim configuration uses roslyn_ls directly.
install_roslyn_language_server() {
  local dotnet="$DOTNET_DIR/dotnet"

  if roslyn_language_server_installed; then
    echo "Roslyn language server already installed"
    return 0
  fi

  if [[ ! -x "$dotnet" ]]; then
    printf 'Error: .NET SDK is required to install Roslyn.\n' >&2
    return 1
  fi

  echo "Roslyn language server not found; installing globally..."
  if ! "$dotnet" tool install --global roslyn-language-server --prerelease; then
    printf 'Error: Roslyn language server installation failed.\n' >&2
    return 1
  fi

  if ! roslyn_language_server_installed; then
    printf 'Error: Roslyn installation completed, but the executable was not found.\n' >&2
    return 1
  fi

  echo "Roslyn language server installed: $HOME/.dotnet/tools/roslyn-language-server"
}

# Install the Tmux Plugin Manager without overwriting an existing path.
# The tmux configuration expects TPM at this exact location.
install_tpm() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"
  local plugin_dir
  local tmp_dir

  if [[ -f "$tpm_dir/tpm" ]]; then
    echo "ok:     TPM already installed"
    return 0
  fi

  if [[ -e "$tpm_dir" || -L "$tpm_dir" ]]; then
    printf 'Error: TPM path exists but is not a valid installation: %s\n' \
      "$tpm_dir" >&2
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    printf 'Error: git is required to install TPM.\n' >&2
    return 1
  fi

  plugin_dir="$(dirname "$tpm_dir")"
  mkdir -p "$plugin_dir"
  tmp_dir="$(mktemp -d "$plugin_dir/.tpm-install.XXXXXX")"

  if ! git clone --depth=1 "$TPM_REPOSITORY" \
    "$tmp_dir/tpm"; then
    rm -rf "$tmp_dir"
    printf 'Error: TPM installation failed.\n' >&2
    return 1
  fi

  if [[ -e "$tpm_dir" || -L "$tpm_dir" ]]; then
    rm -rf "$tmp_dir"
    printf 'Error: TPM path appeared during installation: %s\n' "$tpm_dir" >&2
    return 1
  fi

  if ! mv "$tmp_dir/tpm" "$tpm_dir"; then
    rm -rf "$tmp_dir"
    printf 'Error: could not finalize TPM installation.\n' >&2
    return 1
  fi

  rm -rf "$tmp_dir"
  echo "TPM installed; press the tmux prefix followed by Shift-I to install plugins"
}

run_quietly() {
  if ! "$@" >/dev/null 2>&1; then
    printf 'Error: command failed: %s\n' "$*" >&2
    return 1
  fi
}
