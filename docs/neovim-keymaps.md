# Neovim keymaps

Reference for the keymaps that matter to this config. "LazyVim default"
bindings ship with LazyVim and are not defined in this repo; "custom"
bindings are set in `.config/nvim/lua/config/keymaps.lua` or a plugin spec
under `.config/nvim/lua/plugins/`.

## Diagnostics, symbols and LSP lists (trouble.nvim)

trouble.nvim is enabled with LazyVim's defaults; its panels are the primary
way to browse diagnostics and LSP results.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>xx` | n | Toggle project diagnostics |
| `<leader>xX` | n | Toggle buffer diagnostics |
| `<leader>cs` | n | Document symbols |
| `<leader>cS` | n | LSP references / definitions / implementations |
| `<leader>xL` | n | Location list |
| `<leader>xQ` | n | Quickfix list |

## Signature help

Provided by `lsp_signature.nvim`, the sole signature provider (`bind = true`
in `lua/plugins/lsp-signature.lua`); noice's signature popup is disabled in
`lua/plugins/noice.lua`.

| Key | Mode | Action |
| --- | --- | --- |
| `gK` | n | Signature help |
| `<c-k>` | i | Signature help |

## Inlay hints

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>uh` | n | Toggle inlay hints globally (Snacks) |

Inlay hints are excluded for the `cs` filetype by default
(`lua/plugins/lspconfig.lua`), so C# hints are off until toggled on.

## Window / tmux navigation

Custom (vim-tmux-navigator), `lua/config/keymaps.lua`. At a window edge the
motion crosses into a tmux pane, which needs the matching tmux bindings.

| Key | Mode | Action |
| --- | --- | --- |
| `<C-h>` | n | Window / tmux pane left |
| `<C-j>` | n | Window / tmux pane down |
| `<C-k>` | n | Window / tmux pane up |
| `<C-l>` | n | Window / tmux pane right |

## Search & replace

Custom, `lua/config/keymaps.lua`. Input is literal (no regex or
backreferences); visual mode prefills the search with the selection.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>rr` | n, x | Replace all matches without confirmation |
| `<leader>rc` | n, x | Replace with per-match confirmation |

## Editing

| Key | Mode | Action |
| --- | --- | --- |
| `jk` | i | Exit insert mode |

## Markdown

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>um` | n | Toggle Markdown rendering (render-markdown.nvim) |
