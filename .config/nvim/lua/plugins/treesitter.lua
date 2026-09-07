-- Extra tree-sitter parsers on top of LazyVim's default list
-- (LazyVim sets opts_extend, so ensure_installed here ADDS to its list).
--
-- c_sharp: LazyVim's default list doesn't include csharp; without it, .cs
-- buffers fall back to the built-in cs.vim regex syntax, which cannot
-- recognize user-defined types (class names render as plain text). The
-- parser is registered as `c_sharp` in the current nvim-treesitter.
--
-- sql: LazyVim's defaults include the markdown and markdown_inline
-- parsers, which split fenced code blocks out of markdown; the `sql`
-- parser is what parses the contents of ```sql fences. Without it those
-- blocks render as plain text. Tree-sitter only parses/highlights them —
-- LSP clients attach per filetype, so the sqls server itself stays
-- confined to sql/mysql buffers, not markdown.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c_sharp", "sql" },
    },
  },
}
