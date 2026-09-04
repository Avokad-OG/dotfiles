# Usage

Steps and options that apply to most setups after the OS installer has run.
Per-OS installer behavior and machine-specific notes live in the individual
OS guides ([Arch](arch-setup.md), [Ubuntu](ubuntu-setup.md), [Pi](pi-setup.md),
[macOS](macos-setup.md)) — this page covers what is shared.

## First run after install

These run once, on every new machine:

1. **Neovim / plugins / tools** — start `nvim` once. The first launch
   bootstraps lazy.nvim, installs all configured plugins (versions pinned in
   `.config/nvim/lazy-lock.json`), and Mason installs the LSPs, linters and
   formatters listed in `.config/nvim/lua/plugins/mason.lua`
   (`ensure_installed`).
   - `luacheck` is **not** installed by Mason (its Mason build is
     incompatible with Lua 5.5); it is installed by the per-OS installer
     (Homebrew on macOS, LuaRocks on Linux) and the nvim config puts its
     binary dir on PATH.
2. **tmux / TPM** — reload the config (`prefix + q` does this via the
   `reload` binding) and press `prefix + I` (capital I) once to install the
   TPM plugins configured in `.config/tmux/tmux.conf`.
   - Session persistence: `prefix + Ctrl-s` saves the tree, `prefix + Ctrl-r`
     restores it; continuum auto-saves every 15 minutes and auto-restores on
     server start. Set `@continuum-restore 'off'` in tmux.conf to keep
     auto-save but disable auto-restore.

## Environment overrides (installer tuning)

The installers pull their defaults from `lib.sh` as `${VAR:-default}`, so they
can be overridden per-run with an environment variable. Inline for one run:

```bash
NEOVIM_VERSION=0.12.6 ./install-ubuntu.sh
```

Or exported before the dispatcher:

```bash
export DOTNET_VERSION=10.0.400
export NEOVIM_INSTALL_ROOT="$HOME/.local/opt"
./install.sh
```

Supported overrides (defaults live in `lib.sh`):

| Variable                 | Default                         | Used for                                        |
| ------------------------ | ------------------------------- | ----------------------------------------------- |
| `DOTNET_DIR`             | `~/.dotnet`                     | .NET SDK installation directory                 |
| `DOTNET_VERSION`         | `10.0.400`                      | .NET SDK version (macOS, Ubuntu, Pi)            |
| `LUA_VERSION`            | `5.4`                           | Lua for `luacheck` (Linux)                      |
| `LUA_ROCKS_BIN`          | `~/.luarocks/bin`               | luacheck install dir (Linux)                    |
| `NEOVIM_VERSION`         | `0.12.5`                        | Neovim version (Ubuntu, Pi)                     |
| `NEOVIM_INSTALL_ROOT`    | `/opt`                          | Neovim install dir (Ubuntu, Pi)                 |
| `NERD_FONT_URL`          | Official Meslo LG archive       | Nerd Font download URL                          |
| `DOTNET_INSTALLER_URL`   | Microsoft installer script      | .NET install script URL                         |
| `HOMEBREW_INSTALLER_URL` | Homebrew install script         | Homebrew installer URL (macOS)                  |
| `TPM_REPOSITORY`         | Official TPM repo               | TPM Git repository                              |

Only override download URLs when you trust the source. If you change
`DOTNET_DIR`, also update Neovim's `DOTNET_ROOT` configuration
(`.config/nvim/lua/config/options.lua`).

## .NET / C# support

The nvim config uses the Microsoft **Roslyn** language server (`roslyn_ls`),
installed as a per-user global .NET tool at `~/.dotnet/tools`
(`roslyn-language-server`). The installers add that dir (and `~/.dotnet` when
the SDK is there) to PATH; on a fresh interactive shell both `dotnet` and the
language server tool are reachable. C# formatting maps to csharpier, which
also needs the .NET SDK. Edit path-related config in `.config/nvim/lua/config/options.lua`.

## Editing & reloading configs

Configs are symlinked, so editing the repo file is editing the live file. To
make the running app pick up changes:

- **Neovim** / **kitty** — restart the app.
- **tmux** — `prefix + q` (reload) after editing `.config/tmux/tmux.conf`.
- **Starship** — starts fresh per new shell; no reload needed.
- **keyd / Hyprland** reload and config checking are Arch-specific — see
  [Arch guide](arch-setup.md).

## Editor notes (shared)

- **Markdown formatting** — `markdownlint-cli2` needs an explicit
  `--config ~/.markdownlint-cli2.jsonc` (the config is passed by
  `.config/nvim/lua/plugins/linting.lua`); Prettier (`prettierd` via
  `.config/nvim/lua/plugins/formatting.lua`) wraps Markdown to 80 cols using
  `~/.prettierrc.json`.
- **Obsidian (optional)** — `.config/nvim/lua/plugins/obsidian.lua` ships with
  no workspaces. If you use Obsidian, uncomment its `workspaces` block and
  point it at your vault (any directory containing an `.obsidian` folder).

## Client-side

- **Nerd Font** — install a font in the terminal you use, otherwise LazyVim
  and Starship icons render as boxes (e.g. Meslo LG Nerd Font, the same font
  the installers fetch).
- **Clipboard when headless** — with no display server, nvim clipboard uses
  OSC 52; inside tmux most modern terminals support it. See the
  [Ubuntu guide](ubuntu-setup.md) for the headless caveats.
