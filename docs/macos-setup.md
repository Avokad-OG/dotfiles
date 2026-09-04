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
  installs the per-user global `roslyn-language-server` tool to
  `~/.dotnet/tools`, then adds `~/.dotnet` and `~/.dotnet/tools` to PATH in
  `~/.zshrc`.
- Installs Homebrew when it is missing; existing Homebrew installations are
  updated and upgraded.
- Installs the packages and applications listed in `Brewfile` (including
  Node.js, required by Mason's npm-based linters), then enables the
  brew-installed Powerlevel10k theme and plugins in `~/.zshrc` (run
  `p10k configure` in a new terminal afterwards to pick a prompt style).
- Links the shared dotfiles, the kitty terminal config (Brewfile cask), and
  installs TPM.

The installer is idempotent. Existing dotfiles, unrelated symlinks, and an
existing TPM installation are never overwritten. After the first run, reload
tmux and press the tmux prefix followed by `Shift-I` to install the configured
plugins.

The Xcode Command Line Tools installation is requested through `xcode-select --install` (Apple's install-on-demand mechanism, used for fresh installs); when Apple offers the tools through its Software Update service instead (typically an upgrade), that is used. Interrupting either stops the installer with a cancellation message.
