return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ft = { "markdown" },
    opts = {},
    keys = {
      {
        "<leader>um",
        "<cmd>RenderMarkdown toggle<CR>",
        desc = "Toggle Markdown rendering",
      },
    },
  },
}
