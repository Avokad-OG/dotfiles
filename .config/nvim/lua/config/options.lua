-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.g.autoformat = true

-- Prepend the LuaRocks local bin so luacheck (installed outside Mason,
-- not under the Mason bin configured below) is launchable.
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

-- .NET: apphosts like roslyn-language-server locate their runtime through
-- DOTNET_ROOT (then fall back to the system runtime). Prepend the real dotnet
-- so it wins over any shim, and point DOTNET_ROOT at the SDK install.
-- roslyn's client also re-derives DOTNET_ROOT for the server daemon it spawns
-- from the resolved `dotnet` on PATH; the mise shim resolves to /usr/bin/mise,
-- so the real dotnet must precede the shim or the daemon uses /usr/bin.
local dotnet_root = vim.fn.expand("~/.dotnet")
local dotnet_tools = dotnet_root .. "/tools"
if vim.fn.isdirectory(dotnet_tools) == 1 then
  vim.env.PATH = dotnet_tools .. ":" .. vim.env.PATH
end
if vim.fn.executable(dotnet_root .. "/dotnet") == 1 then
  -- macOS / Ubuntu / Pi: the SDK lives under ~/.dotnet.
  vim.env.DOTNET_ROOT = dotnet_root
  vim.env.PATH = dotnet_root .. ":" .. vim.env.PATH
else
  -- Omarchy: the SDK is managed by mise. Resolve its install root, put it
  -- first on PATH (so `dotnet` is the real binary, not the shim), and point
  -- DOTNET_ROOT at it so apphosts use the SDK's runtime.
  local mise_dotnet = vim.fn.system({ "mise", "which", "dotnet" }):gsub("%s+$", "")
  if vim.v.shell_error == 0 and mise_dotnet ~= "" then
    local mise_root = mise_dotnet:gsub("/dotnet$", "")
    if vim.fn.isdirectory(mise_root .. "/host/fxr") == 1 then
      vim.env.DOTNET_ROOT = mise_root
      vim.env.PATH = mise_root .. ":" .. vim.env.PATH
    end
  end
end
