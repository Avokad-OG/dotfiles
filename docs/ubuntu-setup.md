# Ubuntu / Debian Setup (install-ubuntu.sh)

Setup walkthrough for apt-based systems, written against a headless server
accessed over SSH/tmux.

## Quick start

```bash
git clone <repo-url> ~/omarchy-config
~/omarchy-config/install.sh          # auto-detects the OS, runs install-ubuntu.sh
```

Or run the Ubuntu installer directly:

```bash
~/omarchy-config/install-ubuntu.sh
```

The script is **idempotent** — safe to run repeatedly. It never overwrites
anything: an existing symlink to the repo is left alone, and a file that
already exists (symlink to elsewhere or a real file) is reported and skipped.

## What it does

1. **nvim** — detected via `command -v nvim` or the official release-tarball
   location `/opt/nvim-linux-x86_64/bin/nvim`; installed from the official
   release tarball when absent. (An existing nvim at `/opt` is left alone.)
2. **tmux** — installed via apt only when absent.
3. **unzip** — installed via apt only when absent (Mason needs it to extract
   .zip-based packages such as stylua and lemminx).
4. **python3-venv** — installed via apt (Mason's Python-based tools, e.g.
   xmlformatter, need `ensurepip` to create their virtualenvs; on
   Debian/Ubuntu that lives in the `python3-venv` package).
5. **Symlinks** (user-level only, no `/etc`, no sudo when the packages exist):
   - `.markdownlint-cli2.jsonc` → `~/.markdownlint-cli2.jsonc`
   - `.prettierrc.json` → `~/.prettierrc.json`
   - `.config/nvim` → `~/.config/nvim`
   - `.config/tmux` → `~/.config/tmux`
5. **.NET 10 and Roslyn** — the SDK is installed from Microsoft to
   `~/.dotnet` when missing, followed by the per-user global
   `roslyn-language-server` tool in `~/.dotnet/tools`. These provide C# support
   and the SDK used by csharpier.
6. **Plugin setup** — TPM is installed by the script, but the configured tmux
   plugins still need a one-time `prefix + I` inside tmux. The **first nvim
   launch** bootstraps lazy.nvim, installs all Neovim plugins, and Mason
   installs the tools listed in `lua/plugins/mason.lua` (`ensure_installed`).
   unzip is installed upfront (step 3) so those installs can extract .zip
   packages.

Unlike the Arch installer, this script does **not** install keyd or link
Hyprland configs — those are desktop/keyboard-only and not useful on a
headless server.

## Client-side requirements

- **Nerd Font** — LazyVim renders icons; install a Nerd Font in the terminal
  you SSH from (e.g. Meslo LG Nerd Font, same as macOS), otherwise icons show
  as boxes.
- **OSC 52 clipboard** — with no display server, nvim's clipboard falls back
  to OSC 52. Inside tmux this works in most modern terminals; without tmux it
  depends on terminal support.

## Markdown tooling

- `markdownlint-cli2` is configured with `--config ~/.markdownlint-cli2.jsonc`
  (linting.lua passes it explicitly, since markdownlint-cli2 only
  auto-discovers config in its CWD).
- `prettierd` formats markdown using `~/.prettierrc.json` (proseWrap,
  printWidth 80).

## Notes

- **C# / .NET** — the installer installs the .NET 10 SDK via Microsoft's
  official installer at `~/.dotnet` and the `roslyn-language-server` global
  tool at `~/.dotnet/tools`. `csharp.lua` and `options.lua` use them for C# LSP
  support and csharpier.
- **keyd / hypr** — not installed or linked by this script (headless server).

## nvim on PATH

nvim at `/opt/nvim-linux-x86_64/bin` is added to PATH only
in interactive shells (`~/.bashrc`). Scripts and non-interactive SSH sessions
won't find it. If you need nvim in scripts, add the same export to
`~/.profile`:

```bash
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
```

## Verification

```bash
nvim --version                                   # 0.12.x
TERM=xterm-256color nvim +qa                     # no startup errors
nvim --headless "+checkhealth lazy" +qa          # no failed plugins
nvim --headless "+Lazy list" +qa                 # plugin set matches lazy-lock.json
tmux new -d                                      # tmux.conf loads cleanly
```

First interactive launch may finish installing Mason tools; check `:Mason`
afterwards.
