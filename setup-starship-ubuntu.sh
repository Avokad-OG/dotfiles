#!/usr/bin/env bash
# Enable Starship as the bash prompt on Debian/Ubuntu.
#
# This script installs the binary into ~/.local/bin when missing (official
# GitHub release, glibc build on x86_64, musl on aarch64 because upstream
# publishes no aarch64 glibc build) and adds an init line to ~/.bashrc.
#
# Idempotent: safe to run multiple times; existing ~/.bashrc is preserved.
set -euo pipefail

STARSHIP_BIN_DIR="${STARSHIP_BIN_DIR:-$HOME/.local/bin}"
BASHRC="$HOME/.bashrc"
echo "Enabling Starship for bash: $BASHRC"

# --- Map the CPU architecture to a starship release asset ---------------------
case "$(uname -m)" in
  x86_64 | amd64)
    ASSET="starship-x86_64-unknown-linux-gnu.tar.gz"
    ;;
  aarch64 | arm64)
    ASSET="starship-aarch64-unknown-linux-musl.tar.gz"
    ;;
  *)
    echo "Error: unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac
STARSHIP_URL="${STARSHIP_URL:-https://github.com/starship/starship/releases/latest/download/$ASSET}"

# --- Install the binary when missing ------------------------------------------
starship_bin() {
  if command -v starship >/dev/null 2>&1; then
    command -v starship
    return 0
  fi
  if [[ -x "$STARSHIP_BIN_DIR/starship" ]]; then
    printf '%s\n' "$STARSHIP_BIN_DIR/starship"
    return 0
  fi
  return 1
}

install_starship() {
  local bin
  local tmp_dir

  if bin="$(starship_bin)"; then
    echo "ok:     starship already installed ($bin)"
    return 0
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Error: curl is required to download starship." >&2
    echo "       Install with: sudo apt install curl" >&2
    return 1
  fi

  echo "starship: not installed, downloading $ASSET ..."
  tmp_dir="$(mktemp -d)"

  if ! curl -fsSL "$STARSHIP_URL" -o "$tmp_dir/starship.tar.gz"; then
    rm -rf "$tmp_dir"
    echo "Error: failed to download $STARSHIP_URL" >&2
    return 1
  fi

  if ! tar -xzf "$tmp_dir/starship.tar.gz" -C "$tmp_dir"; then
    rm -rf "$tmp_dir"
    echo "Error: failed to extract starship archive." >&2
    return 1
  fi

  mkdir -p "$STARSHIP_BIN_DIR"
  if ! mv "$tmp_dir/starship" "$STARSHIP_BIN_DIR/starship"; then
    rm -rf "$tmp_dir"
    echo "Error: could not move starship into $STARSHIP_BIN_DIR" >&2
    return 1
  fi
  chmod +x "$STARSHIP_BIN_DIR/starship"
  rm -rf "$tmp_dir"

  if ! bin="$(starship_bin)"; then
    echo "Error: starship did not install to $STARSHIP_BIN_DIR." >&2
    return 1
  fi

  echo "starship: installed ($bin)"
}

# --- Build the block to add to ~/.bashrc ---------------------------------------
# PATH first so `starship` resolves in the same shell that evaluates the init
# line (new tmux panes and non-login shells read only ~/.bashrc, not
# ~/.profile). Ubuntu's default ~/.profile already prepends ~/.local/bin for
# login shells; the export below makes it work everywhere.
readonly BLOCK=(
  '# Starship prompt -- added by setup-starship-ubuntu.sh'
  "export PATH=\"\$PATH:$STARSHIP_BIN_DIR\""
  'eval "$(starship init bash)"'
)

append_block() {
  local line
  local added=0

  if [[ ! -f "$BASHRC" ]]; then
    : >"$BASHRC" # create it
    echo "Created $BASHRC (did not exist)"
  fi

  # Append each line only if it is not already present (idempotent). The PATH
  # export must stay before the eval line.
  for line in "${BLOCK[@]}"; do
    if ! grep -qxF -- "$line" "$BASHRC"; then
      printf '%s\n' "$line" >>"$BASHRC"
      added=1
    fi
  done

  if ((added)); then
    echo "Added starship configuration to $BASHRC"
  else
    echo "Starship already enabled in $BASHRC"
  fi
}

# --- Verify starship loads in an interactive bash ------------------------------
# Launches an interactive bash on purpose: it reads $BASHRC, so this catches
# PATH or init-line mistakes before the user opens a new shell.
verify() {
  if bash -ic 'command -v starship >/dev/null 2>&1' 2>/dev/null; then
    echo "OK: starship is available in bash"
  else
    echo "Warning: starship did not load. Check $BASHRC for errors." >&2
    return 1
  fi
}

install_starship
append_block
verify

echo
echo "Done! Starship is the prompt for new bash sessions."
echo "  * The CURRENT shell has no starship yet - open a new terminal (or"
echo "    run: source $BASHRC)."
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml" ]]; then
  echo "  * Prompt config found; the new prompt is ready."
else
  echo "  * No prompt config yet. Pick a preset to start, e.g.:"
  echo "      starship preset pastel-powerline -o ~/.config/starship.toml"
  echo "    then open a new shell. Tweak ~/.config/starship.toml anytime."
fi
