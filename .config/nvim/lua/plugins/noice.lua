-- noice.nvim: disable the LSP signature-help popup.
--
-- noice overrides `vim.lsp.buf.signature_help` and auto-opens the *documented*
-- signature (signature + docs) when you type a trigger character (`(`/`,`) —
-- this is the bottom floating documentation panel that kept appearing.
--
-- Signature help is instead provided by lsp_signature.nvim (the overload-list
-- float). We only disable noice's signature feature; hover/messages stay intact.
return {
  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        signature = {
          enabled = false,
          auto_open = { enabled = false, trigger = false },
        },
      },
    },
  },
}
