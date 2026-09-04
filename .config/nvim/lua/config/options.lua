-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = true

-- LuaRocks binaries (the installer places luacheck here by default).
local luarocks_bin = vim.env.LUA_ROCKS_BIN or vim.fn.expand("~/.luarocks/bin")
if vim.fn.isdirectory(luarocks_bin) == 1 then
  vim.env.PATH = luarocks_bin .. ":" .. vim.env.PATH
end

-- Mason-installed tools live in mason/bin; nvim-lint can fire before Mason's
-- lazy setup prepends this directory, and GUI-launched nvim may have a
-- minimal PATH. Add it eagerly so linters are always spawnable.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

-- Omarchy provides Node.js via mise shims; without them the npm-based Mason
-- linters (eslint_d, jsonlint, markdownlint-cli2, ...) fail with ENOENT even
-- though their binaries exist (shebang: #!/usr/bin/env node).
local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if vim.fn.isdirectory(mise_shims) == 1 then
  vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end

-- .NET (prepended last so ~/.dotnet ends up first on PATH). .NET apphosts
-- like roslyn-language-server locate their runtime by taking the first
-- `dotnet` on PATH; the mise shim (mise/shims/dotnet -> /usr/bin/mise)
-- resolves to /usr/bin, which has no runtime, so dotnet must precede it.
-- This matches macOS, where dotnet only lives in ~/.dotnet.
local dotnet_root = vim.fn.expand("~/.dotnet")
local dotnet_tools = dotnet_root .. "/tools"
if vim.fn.isdirectory(dotnet_tools) == 1 then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end
if vim.fn.executable(dotnet_root .. "/dotnet") == 1 then
  vim.env.DOTNET_ROOT = dotnet_root
  vim.env.PATH = dotnet_root .. ":" .. vim.env.PATH
end
