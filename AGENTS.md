# AGENTS.md

Editing rules for this dotfiles repo. Configs in `.config/` and `etc/` are
symlinked onto the user's machines, so edits there are live — and edits here
must stay valid on every supported OS (macOS, Ubuntu/Debian, Raspberry Pi OS
Trixie, Arch/Omarchy). No test suite or CI exists: run the checks under
"Verify before finishing".

## Working rules

- Only edit files tracked in git. Never add or edit inside ignored ranges
  (`.config/nvim/lazy-lock.json`, `.config/tmux/plugins/`, `tt.*`/`foo.*`,
  `.DS_Store`) — they are per-machine state.
- NEVER add sensitive or user-identifying content: credentials, keys,
  tokens, auth state, personal account/host names, IPs, or absolute home
  paths. Use `~`/placeholders; keep real secrets in gitignored env or
  credential stores.
- Comments must concern only the file they are in (that code's what/why) —
  never what other files do or repo layout. State real cross-file
  dependencies inline only.
- Keep this file rules-only; do not add repo description here.

## Verify before finishing

- Every changed or added `*.sh` must pass `bash -n`:
  ```sh
  for f in $(git ls-files '*.sh'); do bash -n "$f" || exit 1; done
  ```
- Lint each changed file with the tool that config uses, when installed:
  `shellcheck` on `*.sh`; `luacheck` + `stylua` (2-space, 120 —
  `.config/nvim/stylua.toml`) on `.config/nvim` Lua; `markdownlint-cli2
  --config ~/.markdownlint-cli2.jsonc` + Prettier (`.prettierrc.json`) on
  Markdown.
- For config edits, tell the user the reload step
  (`sudo keyd reload`; `hyprctl reload` + `configerrors`).
- After every change, audit the documentation for anything the change makes
  stale or should mention: check `README.md` and every file under `docs/`
  against the change just made. If the change adds, removes, or modifies
  behavior, tooling, files, or paths that any doc describes — or that any doc
  should newly describe — propose concrete doc edits to the user (do not
  apply them silently). Update the docs only after the user approves the
  proposed changes.

## Installers and `lib.sh`

- Put per-OS logic in `install-*.sh`, shared logic in `lib.sh`; keep
  `install.sh` a thin OS dispatcher.
- Scripts must be robust and fail safe — they run on the user's machine with
  possible `sudo`, so a bug in one must not break the machine or leave it
  half-configured. Follow the established per-role shape (each `install-*.sh`
  sources `lib.sh` after computing `DOTFILES_DIR`; files that don't source it
  are meant to be standalone or invoked as libraries). Always fail loudly on
  trouble rather than continuing silently past an error.
- Idempotency is mandatory: reuse the `*_present()`/`*_installed()` guards,
  symlink only via `link()`/`link_system()`, never overwrite, keep the
  `ok:`/`skip:`/`linked:` status lines. Errors to stderr, exit non-zero,
  clean up temp files.
- Keep version pins and download URLs overridable rather than inline
  literals, and in one obvious place per script (lib.sh defaults for the
  installers; top-of-file defaults for standalone `setup-*.sh`).
- Shell-rc edits go in `setup-*.sh`, invoked with `bash`; keep PATH appends
  idempotent (one line each).

## Neovim config (`.config/nvim/`)

- `lua/config/` = base setup; `lua/plugins/` = one file per plugin/concern,
  registered via LazyVim `import = "plugins"`.
- Fresh-machine tools go in `ensure_installed` of `lua/plugins/mason.lua` —
  except `luacheck` (Mason-incompatible with Lua 5.5; install via
  Homebrew/LuaRocks, wire as the `lua` linter in `linting.lua`).
- Formatters in `formatting.lua`, linters in `linting.lua`.
- C# uses `roslyn_ls` (dotnet global tool at `~/.dotnet/tools`); never
  `csharp-ls`.
- Invoke `markdownlint-cli2` with an explicit `--config
  ~/.markdownlint-cli2.jsonc`.

## App configs

- keyd: edit `etc/keyd/default.conf`, then `sudo keyd reload`. Never use
  `compose:caps` in `.config/hypr/input.lua` — it breaks keyd's Caps Lock
  tap-to-toggle.
- Hyprland `.config/hypr/*.lua` auto-reloads on save; validate with
  `hyprctl configerrors`.
- `.config/tmux/tmux.conf` expects untracked TPM at
  `~/.config/tmux/plugins/tpm` (created by `install_tpm`).
- Keep the symlink targets of `.config/kitty`, `.config/starship.toml`, and
  `.config/nvim` stable — prompts, PATH, and lint configs reference them.
