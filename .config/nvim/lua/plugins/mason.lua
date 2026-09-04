-- Tools auto-installed by Mason on a fresh machine.
-- luacheck is installed outside Mason (Homebrew on macOS and LuaRocks on
-- Linux) because Mason's build is incompatible with Lua 5.5.
return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "bash-language-server",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "lemminx",
        "marksman",
        -- lua-language-server is installed by LazyVim's lsp setup.
        -- Formatters (stylua and shfmt are already LazyVim defaults.)
        "csharpier",
        "prettierd",
        "xmlformatter",
        -- Linters
        "eslint_d",
        "htmlhint",
        "jsonlint",
        "markdownlint-cli2",
        "shellcheck",
      },
    },
  },
}
