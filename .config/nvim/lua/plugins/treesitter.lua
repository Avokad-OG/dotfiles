-- C# treesitter parser for syntax highlighting.
-- LazyVim's default list doesn't include csharp; without it, .cs buffers
-- fall back to the built-in cs.vim regex syntax, which cannot recognize
-- user-defined types (class names render as plain text).
-- Note: the parser is registered as `c_sharp` in the current nvim-treesitter.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- opts_extend is set by LazyVim, so this ADDS to the default list
      ensure_installed = { "c_sharp" },
    },
  },
}
