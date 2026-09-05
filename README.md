# dotfiles

Personal dotfiles and installer scripts for Neovim (LazyVim), tmux, kitty,
Hyprland, Starship, and keyd, designed to be installed side-by-side on my
machines: macOS, Ubuntu/Debian, Raspberry Pi OS (Trixie/aarch64), and
Arch/Omarchy.

## What this repo is

- **Configs** under `.config/` and `etc/` are the live configs, installed by
  symlink onto the target machine rather than copied.
- **Installers** in the repo root (`install*.sh`, `lib.sh`) set up a supported
  OS: install the right tools and create the symlinks.

> Configs and installers must stay valid on every supported OS and be safe to
> re-run. These are the rules AGENTS.md enforces for any edit.

## Install

```bash
git clone <repo-url> ~/dotfiles
~/dotfiles/install.sh     # detects the OS and runs the matching installer
```

`install.sh` dispatches to one of `install-arch…/omarchy`, `install-ubuntu.sh`,
`install-pi.sh`, or `install-macos.sh`. Every installer is **idempotent**: it
never overwrites an existing path, so re-running is safe.

## Common post-install steps

After the first run, most tools need a one-time bootstrap (first Neovim launch
installs plugins and Mason tools; tmux needs `prefix + I` for TPM). See
**[Usage](docs/usage.md)** for the shared steps and what each app installs.

## Supported systems

- [Arch / Omarchy](docs/arch-setup.md)
- [Ubuntu / Debian](docs/ubuntu-setup.md)
- [Raspberry Pi OS](docs/pi-setup.md)
- [macOS](docs/macos-setup.md)

Each OS guide documents its installer and machine-specific behavior.

## Layout

```text
.config/
├── nvim/          -> ~/.config/nvim           (LazyVim)
├── tmux/          -> ~/.config/tmux           (tmux.conf)
├── hypr/          -> ~/.config/hypr           (Hyprland; tracked, not auto-linked)
├── kitty/         -> ~/.config/kitty          (kitty, macOS)
└── starship.toml  -> ~/.config/starship.toml  (Starship prompt)
.markdownlint-cli2.jsonc -> ~/.markdownlint-cli2.jsonc  (Markdown lint config)
.prettierrc.json        -> ~/.prettierrc.json           (Prettier Markdown config)
etc/keyd/default.conf   -> /etc/keyd/default.conf       (keyd remap, root-owned, Arch)
install*.sh  lib.sh     installer scripts (repo root)
docs/        usage.md + per-OS setup guides (see links above)
```

Each file points at its live destination; edits here are live on the machine
once the symlink exists (and reloaded — see the relevant doc).
