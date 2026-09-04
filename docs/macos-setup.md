# macOS Setup

The main dispatcher detects macOS and runs `install-macos.sh`:

```bash
~/omarchy-config/install.sh
```

You can also run the installer directly:

```bash
~/omarchy-config/install-macos.sh
```

## What it does

- Requests installation of Xcode Command Line Tools when they are missing.
- Installs the .NET 10 SDK from Microsoft to `~/.dotnet` when it is missing,
  then installs the per-user global `roslyn-language-server` tool to
  `~/.dotnet/tools`.
- Installs Homebrew when it is missing; existing Homebrew installations are
  updated and upgraded.
- Installs the packages and applications listed in `Brewfile` (including
  Node.js, required by Mason's npm-based linters).
- Links the shared dotfiles, the kitty terminal config (Brewfile cask), and
  installs TPM.

The installer is idempotent. Existing dotfiles, unrelated symlinks, and an
existing TPM installation are never overwritten. After the first run, reload
tmux and press the tmux prefix followed by `Shift-I` to install the configured
plugins.

The Xcode Command Line Tools installation is performed through Apple's
Software Update service. Interrupting it stops the installer with a cancellation
message.
