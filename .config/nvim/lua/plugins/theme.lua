-- Resilient loader for the Omarchy-managed theme spec.
--
-- This used to be a symlink to Omarchy's staged "current theme"
-- (~/.local/state/omarchy/current/theme/neovim.lua). Omarchy rebuilds that
-- directory with `rm -rf` + `mv` on every `omarchy theme set`, so during the
-- swap window (and on fresh clones before the first theme set) the symlink
-- was broken and lazy.nvim failed with:
--
--   Failed to load `plugins.theme`:
--   cannot open .../lua/plugins/theme.lua: No such file or directory
--
-- This file loads the staged spec when it exists and falls back to the
-- LazyVim default theme otherwise, so nvim always starts cleanly.
-- Omarchy migrations only touch this path while it is a symlink, so this
-- file survives `omarchy update`.

local staged = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(staged) == 1 then
  local ok, spec = pcall(dofile, staged)
  if ok and type(spec) == "table" then
    return spec
  end
end

return {
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
}
