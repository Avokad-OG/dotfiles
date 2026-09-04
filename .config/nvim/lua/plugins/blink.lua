-- blink.cmp: disable the completion documentation window.
--
-- The bottom floating window in the screenshot is blink.cmp's *completion*
-- documentation panel (LazyVim enables it via `completion.documentation.auto_show`).
-- It shows the selected completion item's docs (e.g. the <summary>/<param> XML for
-- Console.WriteLine) while typing. This is separate from lsp_signature.nvim, which
-- provides the top overload-list window already (doc_lines = 0).
--
-- Turning auto_show off removes that bottom documentation panel. Docs can still be
-- opened manually on demand if you ever want them.
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        documentation = {
          auto_show = false,
        },
      },
    },
  },
}
