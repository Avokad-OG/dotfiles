# dotfiles

Neovim (LazyVim), tmux, kitty, Hyprland, Starship and keyd configuration.

## Layout

```text
.markdownlint-cli2.jsonc -> ~/.markdownlint-cli2.jsonc (markdown lint config)
.config/
├── nvim/           -> ~/.config/nvim         (LazyVim-based config)
├── tmux/           -> ~/.config/tmux         (tmux.conf)
├── hypr/           -> ~/.config/hypr         (Hyprland: keybindings, monitors, …)
├── kitty/          -> ~/.config/kitty        (kitty terminal, macOS)
└── starship.toml   -> ~/.config/starship.toml (Starship prompt; Ubuntu + Omarchy)
etc/
└── keyd/
    └── default.conf -> /etc/keyd/default.conf  (keyd key remapping, root-owned)
install.sh   installs keyd, then symlinks the configs into ~/.config and /etc (sudo)
```

## Setup on a new machine

```bash
git clone <repo-url> ~/dotfiles
~/dotfiles/install.sh   # detects the OS and runs the matching installer
```

`install.sh` supports Arch/Omarchy, Ubuntu/Debian, Raspberry Pi OS
Trixie/aarch64, and macOS. On Arch/Omarchy it also handles **keyd**: installing
the package if missing, enabling the service, linking `/etc/keyd/default.conf`,
and reloading the config.

See the platform-specific setup guides:

- [Arch / Omarchy](docs/arch-setup.md)
- [Ubuntu / Debian](docs/ubuntu-setup.md)
- [Raspberry Pi OS](docs/pi-setup.md)
- [macOS](docs/macos-setup.md)

The script is **idempotent** — safe to run repeatedly. It never overwrites
anything: an existing symlink to the repo is left alone, and a file that already
exists (symlink to elsewhere or a real file) is reported and skipped, so it
never clobbers local state.

## Environment overrides

The installers define defaults in `lib.sh`, but supported values can be
overridden through environment variables. Set them inline for one run:

```bash
NEOVIM_VERSION=0.12.6 ./install-ubuntu.sh
```

Or export them before using the main dispatcher:

```bash
export DOTNET_VERSION=10.0.400
export NEOVIM_INSTALL_ROOT="$HOME/.local/opt"
./install.sh
```

Supported overrides:

| Variable                 | Default                            | Used for                                       |
| ------------------------ | ---------------------------------- | ---------------------------------------------- |
| `DOTNET_DIR`             | `~/.dotnet`                        | .NET SDK installation directory                |
| `DOTNET_VERSION`         | `10.0.400`                         | .NET SDK version on macOS, Ubuntu, and Pi      |
| `LUA_VERSION`            | `5.4`                              | Lua version used for luacheck on Linux         |
| `LUA_ROCKS_BIN`          | `~/.luarocks/bin`                  | LuaRocks user-binary directory on Linux        |
| `NEOVIM_VERSION`         | `0.12.5`                           | Neovim version on Ubuntu and Pi                |
| `NEOVIM_INSTALL_ROOT`    | `/opt`                             | Neovim installation directory on Ubuntu and Pi |
| `NERD_FONT_URL`          | Official Meslo LG Nerd Font URL    | Nerd Font archive                              |
| `DOTNET_INSTALLER_URL`   | Microsoft’s official installer URL | .NET installer script                          |
| `HOMEBREW_INSTALLER_URL` | Homebrew’s official installer URL  | Homebrew installer on macOS                    |
| `TPM_REPOSITORY`         | Official TPM repository            | TPM Git repository                             |

The macOS, Ubuntu, and Raspberry Pi installers also install the
`roslyn-language-server` .NET global tool after installing the .NET SDK. It is
installed for the current user at `~/.dotnet/tools` and used by the configured
`roslyn_ls` Neovim server.

Only override download URLs when you trust the replacement source. If
`DOTNET_DIR` is changed, update Neovim’s `DOTNET_ROOT` configuration as well.

Then:

1. **Neovim** — first launch bootstraps lazy.nvim and installs plugins
   (`lazy-lock.json` pins versions). Mason auto-installs the LSPs/linters/
   formatters listed in `nvim/lua/plugins/mason.lua`.
2. **Node.js/npm** — required by Mason's npm-based linters. Installed by the
   macOS/Ubuntu/Pi installers; on Omarchy the installer ensures it via mise.
3. **luacheck** (linter) — installed automatically via Homebrew on macOS and
   LuaRocks on Linux, not Mason (Mason's build is incompatible with Lua 5.5). On
   Linux, the default installation location is `~/.luarocks/bin`, which the nvim
   config adds to PATH. The Ubuntu/Pi installers also install the matching
   `liblua<version>-dev` headers, which luarocks needs to build luacheck's C
   dependency (luafilesystem).
4. **tmux** — TPM is installed automatically by the per-OS installer. Reload
   with the `q` binding or `tmux source-file ~/.config/tmux/tmux.conf`, then
   press prefix + I (uppercase) once to install the configured plugins.
   `prefix + Ctrl-s` saves the session tree; `prefix + Ctrl-r` restores it.
   continuum auto-saves every 15 minutes and auto-restores on server start (keep
   auto-save but disable auto-restore with `set -g @continuum-restore 'off'` in
   tmux.conf).
5. **Hyprland** — config is Lua-based and auto-reloads on save; validate changes
   with `hyprctl reload` then `hyprctl configerrors`.

## keyd (key remapping)

`keyd` remaps keys at the input-device level (below Hyprland/XKB), so it works
system-wide (TTYs included) and with Wayland. The config is
`/etc/keyd/default.conf`, which `install.sh` symlinks to `etc/keyd/default.conf`
in this repo — edit the repo file, commit, and reload.

### What it maps (MacBook Pro 12,1)

- **Caps Lock** — tap toggles Caps Lock; **hold** activates the arrow layer:
  - `h/j/k/l` → `← ↓ ↑ →` while held.
- The physical **Fn** key is left untouched — its firmware combos still work:
  - `Fn + arrows` → Home/End/PageUp/PageDown (intercepted by keyboard firmware,
    not remappable in software),
  - `Fn + F1..F12` → switches the top row between media keys and function keys
    (`hid_apple` `fnmode=2`: media keys by default).

### Install / enable

`install.sh` does all of this automatically — the manual steps are:

```bash
sudo pacman -S keyd              # or: omarchy pkg add keyd
sudo systemctl enable --now keyd
sudo ln -s ~/dotfiles/etc/keyd/default.conf /etc/keyd/default.conf
sudo keyd reload
```

### Reload after editing

```bash
sudo keyd reload
```

Config errors appear in the journal: `sudo journalctl -eu keyd`. Emergency reset
if a bad config locks the keyboard: press `backspace + escape + enter`
(terminates keyd).

### Hyprland requirement

`~/.config/hypr/input.lua` must **not** use the `compose:caps` XKB option — it
makes the Caps Lock keycode emit Compose instead of toggling caps lock, which
breaks the tap-to-toggle behavior. Current options:
`kb_options = "shift:both_capslock_cancel,grp:alts_toggle"`.

## Machine-specific requirements

- **.NET 10 SDK and Roslyn language server** for C# support: the macOS, Ubuntu,
  and Raspberry Pi installers install the SDK via Microsoft's official installer
  at `~/.dotnet`, then install `roslyn-language-server` as a per-user global
  tool at `~/.dotnet/tools`. The Omarchy installer installs the SDK via mise
  (`mise use -g dotnet@latest`) and the same global tool. The nvim config sets
  `DOTNET_ROOT` and adds the default tool directory to PATH automatically when
  the SDK is present.

## Useful link

- [UTM macOS --> Ubuntu activate Shared folder:
  https://dev.to/smyekh/the-oci-developers-workflow-bridging-your-mac-and-local-vm-with-a-shared-folder-34ic]
