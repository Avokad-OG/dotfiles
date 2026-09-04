-- Override LazyVim's LSP options.
--
-- LazyVim enables inlay hints for all LSP languages by default
-- (inlay_hints.enabled = true). For C# (roslyn_ls) these show lambda/parameter
-- name & type hints ("middleware:", "HttpContext context", "value:", ...)
-- as virtual text you can't place the cursor on.
--
-- Exclude "cs" so C# inlay hints are OFF by default. They can still be toggled
-- on/off with <M-i> (see lua/config/keymaps.lua).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        exclude = { "vue", "cs" },
      },
    },
  },
}
