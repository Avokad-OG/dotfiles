-- Linters configured for the tools installed via Mason.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- markdownlint-cli2 only auto-discovers config in the directory it's
        -- launched from (nvim's CWD), so a config in ~/ is silently ignored
        -- when editing files in other projects. Pass it explicitly instead.
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.expand("~/.markdownlint-cli2.jsonc"), "-" },
        },
      },
      linters_by_ft = {
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        html = { "htmlhint" },
        json = { "jsonlint" },
        markdown = { "markdownlint-cli2" },
        sh = { "shellcheck" },
        zsh = { "shellcheck" },
        -- luacheck installed outside Mason (Homebrew on macOS, LuaRocks on Linux)
        lua = { "luacheck" },
      },
    },
  },
}
