#!/usr/bin/env bash
# Enable Powerlevel10k installed via Homebrew so that `p10k configure` works.
#
# `p10k` is not a standalone binary; it is a zsh function defined by the
# theme. It only exists after the theme is sourced from ~/.zshrc. This script
# ensures ~/.zshrc sources the brew-installed theme (and the brew-installed
# zsh-autosuggestions / zsh-syntax-highlighting plugins) and verifies p10k
# loads. Run `p10k configure` afterwards to start the interactive wizard.
#
# Idempotent: safe to run multiple times; existing ~/.zshrc is preserved.
set -euo pipefail

ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
echo "Enabling Powerlevel10k for zsh: $ZSHRC"

if [[ "${SHELL##*/}" != "zsh" ]]; then
  echo "Warning: your login shell is ${SHELL##*/}, not zsh." >&2
  echo "         This configures $ZSHRC, which only zsh reads, so the" >&2
  echo "         prompt will not change until you switch: chsh -s /bin/zsh" >&2
fi

# --- Locate the Homebrew prefix ----------------------------------------------
find_brew_prefix() {
  if command -v brew >/dev/null 2>&1; then
    brew --prefix
    return 0
  fi
  # Fall back to Homebrew's standard locations if brew is not on PATH.
  for p in /opt/homebrew /usr/local; do
    if [[ -d "$p/share/powerlevel10k" ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done
  return 1
}

if ! PREFIX="$(find_brew_prefix)"; then
  echo "Error: Homebrew prefix not found. Is Homebrew installed?" >&2
  exit 1
fi
echo "Homebrew prefix: $PREFIX"

# --- Required files -----------------------------------------------------------
THEME="$PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"
AUTOSUG="$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX="$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

for f in "$THEME" "$AUTOSUG" "$SYNTAX"; do
  if [[ ! -f "$f" ]]; then
    echo "Error: not found: $f" >&2
    echo "       Install with: brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting" >&2
    exit 1
  fi
done

# --- Build the block to add to ~/.zshrc ---------------------------------------
# Order matters: instant prompt first, theme, autosuggestions, then
# zsh-syntax-highlighting last (its docs require it after the prompt).
readonly BLOCK=(
  '# Powerlevel10k (Homebrew) -- added by setup-p10k.sh'
  'if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then'
  '  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"'
  'fi'
  "source $THEME"
  "source $AUTOSUG"
  "source $SYNTAX"
  '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh'
)

# Append each line only if it is not already present (idempotent).
# Appending in order preserves the required relative order.
if [[ ! -f "$ZSHRC" ]]; then
  : >"$ZSHRC" # create it
  echo "Created $ZSHRC (did not exist)"
fi

added=0
for line in "${BLOCK[@]}"; do
  if ! grep -qxF -- "$line" "$ZSHRC"; then
    printf '%s\n' "$line" >>"$ZSHRC"
    added=1
  fi
done

if ((added)); then
  echo "Added powerlevel10k configuration to $ZSHRC"
else
  p10k_cfg="${P10K_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.p10k.zsh}"
  if [[ -f "$p10k_cfg" ]]; then
    echo "Powerlevel10k already configured; skipping."
    exit 0
  fi
  echo "Powerlevel10k already enabled in $ZSHRC; open a new terminal and run:"
  echo "  p10k configure"
  exit 0
fi

# --- Verify p10k loads in an interactive zsh -----------------------------------
if zsh -ic 'whence -w p10k' 2>/dev/null | grep -q '^p10k: function'; then
  echo "OK: p10k is available"
else
  echo "Warning: p10k did not load. Check $ZSHRC for errors." >&2
  exit 1
fi

echo
p10k_cfg="${P10K_CONFIG_FILE:-${ZDOTDIR:-$HOME}/.p10k.zsh}"
echo "Done! p10k is configured for new zsh sessions."
echo "  * The CURRENT terminal has no p10k loaded yet - open a new terminal"
echo "    window (or run: source $ZSHRC)."
if [[ -f "$p10k_cfg" ]]; then
  echo "  * Prompt style config found ($p10k_cfg); the new prompt is ready."
else
  echo "  * No prompt style config yet: run  p10k configure  in a new"
  echo "    terminal to pick a style (writes $p10k_cfg)."
fi
