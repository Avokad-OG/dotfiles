-- C# via the Microsoft Roslyn language server (roslyn_ls), with csharp-ls
-- kept disabled. LazyVim installs and runs roslyn_ls through Mason (the
-- roslyn-language-server package); it only starts inside a project
-- (.sln/.csproj above the file).
--
-- LazyVim enables inlay hints for all LSP languages by default
-- (inlay_hints.enabled = true). For roslyn_ls these show lambda/parameter
-- name & type hints ("middleware:", "HttpContext context", "value:", ...)
-- as virtual text you can't place the cursor on, so exclude "cs" to keep
-- them OFF by default. <leader>uh (LazyVim's Snacks toggle) turns them on.

-- SQL via the sqls language server (sqls-server/sqls). The `sqls` binary is
-- installed through Mason on fresh machines; enabling it here is what makes
-- nvim-lspconfig start it. lspconfig defaults restrict it to `sql`/`mysql`
-- buffers and a config.yml at the project root. Nvim only requires a
-- workspace for servers that opt in (workspace_required), so sqls also
-- attaches to standalone .sql files; database connections are defined in
-- sqls' config.yml when needed.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "cs" },
      },
      servers = {
        roslyn_ls = {},
        csharp_ls = false,
        sqlls = {},
      },
    },
  },
}
