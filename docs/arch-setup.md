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
  tmux, git, unzip, ...) and ensures Node.js and the .NET SDK are installed
  via mise.
- Applies only the repo-owned Neovim and tmux configs:
  - Backs up Omarchy's stock `~/.config/nvim` and symlinks the repo's Neovim
    config in its place (the repo reimplements Omarchy's `theme.lua` symlink
    as a resilient file, so `omarchy theme set` keeps working in Neovim).
  - Symlinks `~/.config/tmux/tmux.conf` only while that file is still the
    stock Omarchy default; a locally edited file is left alone.
- Leaves Hyprland, kitty, and Starship to Omarchy to manage.
- Installs keyd with `omarchy pkg add`, enables the `keyd` service, and links
  `etc/keyd/default.conf` to `/etc/keyd/default.conf`.
- Installs TPM and luacheck if missing.

The installer is idempotent: it adopts a stock Omarchy file only once (backing
it up first) and never touches a locally edited file or an unrelated symlink.
After the first run, reload tmux and press `prefix + Shift-I` to install the
configured TPM plugins.

### Omarchy-managed paths

`~/.config/tmux/tmux.conf` and `~/.config/nvim` replace configs Omarchy seeds
from `/etc/skel`. Omarchy's reset commands copy over the destination rather
than un-linking it, so they write *through* the repo symlinks:

- `omarchy refresh tmux` restores the stock `tmux.conf` into the repo file.
- `omarchy reinstall` / `omarchy reinstall-configs` replay `/etc/skel` and can
  overwrite the symlinked Neovim tree.

After either, `git status` in the repo shows the overwritten files; restore
your config with `git restore -- .config/tmux .config/nvim`, or re-run the
installer. Normal `omarchy update` only runs one-time migrations and does not
touch these paths.

## .NET

The Omarchy installer ensures the .NET SDK via mise (`mise use -g
dotnet@latest`); the Roslyn language server itself is installed by Neovim
through Mason on first use. If you don't need C# / csharpier, this is
optional.

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

- **Caps Lock** — a pure Fn modifier; while held:
  - `h/j/k/l` → `← ↓ ↑ →`
  - `1-9` → `Ctrl+b <n>` (tmux window switch)
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

### Hyprland

No Hyprland change is needed for keyd: Caps Lock is a pure Fn modifier, so
keyd never emits the Caps Lock keycode and Omarchy's default `compose:caps`
input option is unaffected.
