-- lsp_signature: signature + documentation as a floating window.
--
-- This is the replacement for the noice/native "documented signature" popup we
-- disabled in plugins/noice.lua, and it ADDS what that didn't have:
--   - the full overload list (all signatures shown, active one highlighted),
--   - cycling through overloads via select_signature_key,
--   - active-parameter highlight via hi_parameter.
--
-- It becomes the single signature provider through bind = true.
return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    -- Take over the textDocument/signatureHelp handler (sole provider).
    bind = true,

    -- Number of documentation lines to show below the signature.
    -- Increase to see more of the doc-block; 0 = signature only (no docs).
    doc_lines = 15,

    -- Window sizing (max_height is clamped to available screen space).
    max_height = 20,
    -- max_width must be an integer (nvim_open_win rejects floats).
    max_width = function()
      return math.floor(vim.api.nvim_win_get_width(0) * 0.8)
    end,

    always_trigger = false,
    handler_opts = { border = "rounded" },

    -- Floating window + next-parameter hint.
    floating_window = true,
    hint_enable = true,

    -- Highlight the active parameter in the signature.
    hi_parameter = "LspSignatureActiveParameter",

    -- Cycle to the next overload (signature filtering).
    --
    -- WARNING: do NOT use "<S-u>" here. In Vim/Neovim, <S-u> IS the
    -- capital letter "U", and lsp_signature binds this as a buffer-local
    -- insert-mode mapping on every buffer an LSP server attaches to. That
    -- swallows every capital "U" you try to type (e.g. in .cs files with
    -- roslyn attached), because the key is consumed by the mapping instead
    -- of inserting the character. Left unset (nil) = cycling disabled.
    select_signature_key = nil,
    -- If you do want cycling, pick a key that can't be typed as text, e.g.
    -- "<M-n>" (must be reachable as Alt in your terminal; on macOS the
    -- Option key is often a dead key, so verify it reaches Neovim):
    -- select_signature_key = "<M-n>",
  },
  config = function(_, opts)
    require("lsp_signature").setup(opts)
  end,
}
