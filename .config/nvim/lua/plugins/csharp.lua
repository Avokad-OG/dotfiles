-- C# support: use the Microsoft Roslyn language server (roslyn_ls) instead of
-- csharp-ls. The per-OS installers install roslyn_ls as a dotnet global tool:
--
--   dotnet tool install --global roslyn-language-server --prerelease
--
-- (binary lands in ~/.dotnet/tools, which options.lua puts on nvim's PATH).
-- Note: the server only starts inside a project (.sln/.csproj above the file).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        roslyn_ls = {},
        -- csharp-ls is replaced by roslyn_ls; keep it disabled even if the
        -- mason package is still installed somewhere
        csharp_ls = false,
      },
    },
  },
}
