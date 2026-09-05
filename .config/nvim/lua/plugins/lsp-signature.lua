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
    select_signature_key = "<S-u>",
  },
  config = function(_, opts)
    require("lsp_signature").setup(opts)
  end,
}
