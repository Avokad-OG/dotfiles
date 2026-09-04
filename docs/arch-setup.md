# Arch / Omarchy Setup

The main dispatcher detects Arch Linux and runs `install-omarchy.sh`:

```bash
~/omarchy-config/install.sh
```

You can also run the installer directly:

```bash
~/omarchy-config/install-omarchy.sh
```

## What it does

- Uses Omarchy's preinstalled toolchain (Node.js via mise, luarocks, nvim,
  tmux, git, unzip, ...) and ensures Node.js and the .NET SDK (with the
  roslyn-language-server tool) are installed via mise.
- Links the shared dotfiles and the Hyprland configuration.
- Links the kitty configuration.
- Installs `keyd` through `omarchy pkg add`.
- Enables and reloads the `keyd` service.
- Installs TPM and luacheck if they are missing.

The installer is idempotent: existing files and unrelated symlinks are never
overwritten. TPM is cloned once to `~/.config/tmux/plugins/tpm`; after the
first run, reload tmux and press the tmux prefix followed by `Shift-I` to
install the configured plugins.

The Arch installer does not install the .NET SDK automatically. Install .NET
10 separately if C# support is needed.
