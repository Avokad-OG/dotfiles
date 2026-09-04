-- Obsidian vault integration (community fork: obsidian-nvim/obsidian.nvim).
-- The original epwalsh/obsidian.nvim has been unmaintained since 2024;
-- this fork is the actively maintained continuation (v3.16.x+).
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ft = "markdown",
  cmd = "Obsidian",
  opts = {
    -- New LSP-based architecture (recommended by the fork). Functionality is
    -- exposed via the in-process `obsidian-ls` LSP client instead of
    -- `:Obsidian*` commands:
    --   - type `[[`, `#`, or `[^` in a markdown buffer for completions
    --   - `gra` (LSP code actions) for note-specific actions
    -- Set to `true` to restore the classic `:ObsidianNew`/`:ObsidianSearch`/...
    -- commands (deprecated, removed in 4.0.0).
    legacy_commands = false,
    picker = {
      name = "snacks.pick", -- LazyVim's default picker (snacks.nvim)
    },
    -- Workspaces are opt-in; if you use Obsidian, point this at your own
    -- vault (any directory containing an .obsidian folder), e.g.:
    --   workspaces = {
    --     { name = "my-vault", path = "~/Documents/my-vault" },
    --   },
  },
}
