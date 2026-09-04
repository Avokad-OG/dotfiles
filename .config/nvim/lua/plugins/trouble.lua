-- C# signature help is handled by noice.nvim, which auto-opens the
-- documented signature on `(` / `,` and overrides vim.lsp.buf.signature_help.
-- This keymap is just an on-demand trigger for the same documented popup
-- (noice renders it). Cursor must be at/after the opening paren, since
-- Roslyn only returns overloads there.
--
-- IMPORTANT: override the key on the *trouble.nvim* spec, because that's the
-- plugin that owns LazyVim's default <leader>cS binding (set in editor.lua).
return {
  "folke/trouble.nvim",
  enabled = false,
  keys = {
    {
      "<leader>cS",
      function()
        vim.lsp.buf.signature_help()
      end,
      desc = "Signature help (documented)",
    },
  },
}
