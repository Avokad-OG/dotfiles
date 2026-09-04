# Arch / Omarchy Setup

The dispatcher detects Arch Linux and runs `install-omarchy.sh`:

```bash
~/dotfiles/install.sh
```

You can also run the installer directly:

```bash
~/dotfiles/install-omarchy.sh
```

## What it does

- Uses Omarchy's preinstalled toolchain (Node.js via mise, luarocks, nvim,
  tmux, git, unzip, ...) and ensures Node.js and the .NET SDK (with the
  `roslyn-language-server` global tool) are installed via mise.
- Links the shared dotfiles plus the Hyprland, kitty, and Starship
  (`starship.toml`) configs — Omarchy's bash init enables Starship, so the
  tracked style applies here.
- Installs keyd with `omarchy pkg add`, enables the `keyd` service, and links
  `etc/keyd/default.conf` to `/etc/keyd/default.conf`.
- Installs TPM and luacheck if missing.

The installer is idempotent: existing files and unrelated symlinks are never
overwritten. After the first run, reload tmux and press `prefix + Shift-I` to
install the configured TPM plugins.

## .NET

The Omarchy installer ensures the .NET SDK via mise (`mise use -g
dotnet@latest`) and the same global `roslyn-language-server` tool. If you
don't need C# / csharpier, this is optional.

## keyd (key remapping)

`keyd` remaps keys at the input-device level (below Hyprland/XKB), so it works
system-wide (TTYs included) and with Wayland. The config is
`/etc/keyd/default.conf`, which `install.sh` symlinks to `etc/keyd/default.conf`
in this repo — edit the repo file, commit, and reload.

`install.sh` does this all automatically; the manual equivalents:

```bash
sudo pacman -S keyd              # or: omarchy pkg add keyd
sudo systemctl enable --now keyd
sudo ln -s ~/dotfiles/etc/keyd/default.conf /etc/keyd/default.conf
sudo keyd reload
```

### What it maps (MacBook Pro 12,1)

- **Caps Lock** — tap toggles Caps Lock; **hold** activates the arrow layer:
  - `h/j/k/l` → `← ↓ ↑ →` while held.
- The physical **Fn** key is left untouched — its firmware combos still work:
  - `Fn + arrows` → Home/End/PageUp/PageDown (intercepted by keyboard
    firmware, not remappable in software),
  - `Fn + F1..F12` → switches the top row between media keys and function
    keys (`hid_apple` `fnmode=2`: media keys by default).

### Reload after editing

```bash
sudo keyd reload
```

Config errors appear in the journal: `sudo journalctl -eu keyd`. Emergency
reset if a bad config locks the keyboard: press `backspace + escape + enter`
(terminates keyd).

### Hyprland requirement

`~/.config/hypr/input.lua` must **not** use the `compose:caps` XKB option — it
makes the Caps Lock keycode emit Compose instead of toggling caps lock, which
breaks the tap-to-toggle behavior. Current options:
`kb_options = "shift:both_capslock_cancel,grp:alts_toggle"`.
