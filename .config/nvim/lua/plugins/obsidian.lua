-- Obsidian vault integration (community fork: obsidian-nvim/obsidian.nvim).
-- The original epwalsh/obsidian.nvim has been unmaintained since 2024;
-- this fork is the actively maintained continuation (v3.16.x+).
--
-- The fork requires at least one workspace, so this plugin is opt-in: it is
-- enabled only when a per-machine spec file exists at
-- ~/.config/obsidian-nvim/workspaces.lua. That file returns the workspaces
-- list (path, name, and per-workspace `overrides` such as the templates
-- folder), which keeps personal vault config out of this repo. Example:
--   return {
--     {
--       name = "personal",
--       path = "~/vaults/personal",
--       overrides = { templates = { folder = "Templates" } },
--     },
--   }
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ft = "markdown",
  cmd = "Obsidian",

  enabled = function()
    return vim.fn.filereadable(vim.fn.expand("~/.config/obsidian-nvim/workspaces.lua")) == 1
  end,

  opts = function()
    -- New LSP-based architecture (recommended by the fork). Functionality is
    -- exposed via the in-process `obsidian-ls` LSP client instead of
    -- `:Obsidian*` commands:
    --   - type `[[`, `#`, or `[^` in a markdown buffer for completions
    --   - `gra` (LSP code actions) for note-specific actions
    -- Set to `true` to restore the classic `:ObsidianNew`/`:ObsidianSearch`/...
    -- commands (deprecated, removed in 4.0.0).
    local spec_file = vim.fn.expand("~/.config/obsidian-nvim/workspaces.lua")
    local ok, workspaces = pcall(dofile, spec_file)
    if not ok then
      vim.notify(
        "Failed to load Obsidian workspaces spec: " .. tostring(workspaces),
        vim.log.levels.ERROR
      )
      workspaces = {}
    end
    return {
      legacy_commands = false,
      picker = {
        name = "snacks.picker", -- LazyVim's default picker (snacks.nvim)
      },
      workspaces = workspaces,
    }
  end,
}
