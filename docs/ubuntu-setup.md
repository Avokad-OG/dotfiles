# Ubuntu / Debian Setup (install-ubuntu.sh)

Setup walkthrough for apt-based systems, written against a headless server
(Ubuntu 24.04) accessed over SSH/tmux.

## Quick start

```bash
git clone <repo-url> ~/dotfiles
~/dotfiles/install.sh          # auto-detects the OS, runs install-ubuntu.sh
```

Or run the Ubuntu installer directly:

```bash
~/dotfiles/install-ubuntu.sh
```

The script is **idempotent** — safe to run repeatedly. It never overwrites
anything: an existing symlink to the repo is left alone, and a file that already
exists (symlink to elsewhere or a real file) is reported and skipped.

## What it does

1. **nvim** — detected via `command -v nvim` or the official release-tarball
   location `/opt/nvim-linux-x86_64/bin/nvim`; installed from the official
   release tarball when absent. (An existing nvim at `/opt` is left alone.)
2. **tmux** — installed via apt only when absent.
3. **unzip** — installed via apt only when absent (Mason needs it to extract
   .zip-based packages such as stylua and lemminx).
4. **python3-venv** — installed via apt (Mason's Python-based tools, e.g.
   xmlformatter, need `ensurepip` to create their virtualenvs; on Debian/Ubuntu
   that lives in the `python3-venv` package).
5. **.NET 10 and Roslyn** — the SDK is installed from Microsoft to `~/.dotnet`
   when missing, followed by the per-user global `roslyn-language-server` tool
   in `~/.dotnet/tools`. These provide C# support and the SDK used by csharpier.
6. **Plugin hosts** — TPM is installed by the script, plus the **first nvim
   launch** bootstraps lazy.nvim, installs all Neovim plugins, and Mason
   installs the tools listed in `lua/plugins/mason.lua` (`ensure_installed`).
   unzip (step 3) is installed upfront so those installs can extract .zip
   packages.
7. **Symlinks** (user-level only, no `/etc`, no sudo once the packages exist):
   - `.config/nvim` → `~/.config/nvim`
   - `.config/tmux` → `~/.config/tmux`
   - `.config/starship.toml` → `~/.config/starship.toml` (linked before the
     Starship setup in step 8 so the new prompt already has a style)
   - `.markdownlint-cli2.jsonc` → `~/.markdownlint-cli2.jsonc`
   - `.prettierrc.json` → `~/.prettierrc.json`
8. **Starship prompt** — Ubuntu keeps bash as the login shell, and Powerlevel10k
   requires zsh, so the p10k-style prompt here is **Starship** (macOS keeps
   zsh + Powerlevel10k via `setup-p10k-macos.sh`). `setup-starship-ubuntu.sh`
   downloads the official release binary into `~/.local/bin` (glibc build on
   x86_64, musl on aarch64) when missing and appends
   `eval "$(starship init bash)"` to `~/.bashrc`, so the prompt shows in every
   new bash session — no shell switch needed. The prompt style is tracked in
   this repo at `.config/starship.toml` (symlinked in step 7), so edit the repo
   file and commit to change it. To start over from a preset instead, overwrite
   the repo file:

   ```bash
   cd ~/dotfiles   # or wherever this repo is cloned
   starship preset pastel-powerline -o .config/starship.toml
   # then open a new shell; the change is tracked once committed
   ```

   Import the prompt icons client-side too — see the Nerd Font note below.

Unlike the Arch installer, this script does **not** install keyd or link
Hyprland configs — those are desktop/keyboard-only and not useful on a headless
server.

## After first install

- **tmux plugins** — with TPM installed, press `prefix + I` once inside tmux to
  load the configured plugins (after reloading the config — shared controls are
  in [Usage](usage.md)).
- **Mason tools** — the first interactive nvim launch finishes installing the
  Mason tool list; check `:Mason` afterwards.

## Tools on PATH (~/.bashrc)

The installer appends PATH exports for the .NET SDK (`~/.dotnet` and
`~/.dotnet/tools`, so `dotnet` and `roslyn-language-server` are reachable),
luacheck (`~/.luarocks/bin`) and nvim (`/opt/nvim-linux-x86_64/bin`) to
`~/.bashrc`. These apply to interactive shells only; scripts and non-interactive
SSH sessions won't see them. If you need the tools in scripts, add the same
exports to `~/.profile`:

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
