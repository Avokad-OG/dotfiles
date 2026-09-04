# Raspberry Pi OS Setup

`install.sh` automatically runs `install-pi.sh` on Raspberry Pi OS 64-bit
Trixie/aarch64:

```bash
~/omarchy-config/install.sh
```

You can also run the installer directly:

```bash
~/omarchy-config/install-pi.sh
```

## What it does

- Updates and upgrades the Debian package index.
- Installs the development tools, Node.js/npm, Neovim, tmux, and font
  prerequisites.
- Installs the .NET 10 SDK from Microsoft to `~/.dotnet` when it is missing,
  then installs the per-user global `roslyn-language-server` tool to
  `~/.dotnet/tools`.
- Links the shared dotfiles and installs TPM.

The installer is idempotent: existing files and unrelated symlinks are never
overwritten. TPM is cloned once to `~/.config/tmux/plugins/tpm`; after the
first run, reload tmux and press the tmux prefix followed by `Shift-I` to
install the configured plugins.
