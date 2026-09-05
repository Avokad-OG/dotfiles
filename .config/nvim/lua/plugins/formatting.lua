-- Formatters configured for the tools installed via Mason.
-- LazyVim defaults are merged in (lua = stylua, sh = shfmt, fish = fish_indent).
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- prettierd (Mason package "prettierd", bundles prettier itself)
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        less = { "prettierd" },
        html = { "prettierd" },
        markdown = { "prettierd" },
        yaml = { "prettierd" },
        graphql = { "prettierd" },
        -- csharpier (requires the .NET SDK, see options.lua DOTNET_ROOT setup)
        cs = { "csharpier" },
        -- xmlformatter (Mason binary is named `xmlformat`)
        xml = { "xmlformatter" },
      },
    },
  },
}
