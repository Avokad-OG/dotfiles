-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Press `jk` (in insert mode) to exit back to normal mode
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode with jk" })

-- C-h/j/k/l: move between nvim windows, and into tmux panes at the edge
-- (commands provided by the vim-tmux-navigator plugin).
vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { desc = "Window/Tmux Left" })
vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { desc = "Window/Tmux Down" })
vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { desc = "Window/Tmux Up" })
vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "Window/Tmux Right" })

-- Toggle LSP inlay hints (auto-appended parameter/type names) in the current
-- buffer. Inlay hints are off by default, so this mapping turns them on/off.
vim.keymap.set("n", "<M-i>", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { desc = "Toggle inlay hints" })

-- Search and replace in the current buffer (editor-style: input is treated literally)
-- <leader>rr: replace all matches without confirmation
-- <leader>rc: ask for confirmation before each replacement
-- (visual mode prefills the search with the selection)
local function get_visual_selection()
  -- call after leaving Visual mode, so the '< '> marks are up to date
  local mode = vim.fn.visualmode() -- "v", "V" or "\22" (blockwise)
  if not mode or mode == "" then
    return ""
  end
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  if mode == "V" then
    -- linewise: '> col is a MAX_INT sentinel that getregion mishandles
    return table.concat(vim.fn.getline(start_pos[2], end_pos[2]), "\n")
  end
  local lines = vim.fn.getregion(start_pos, end_pos, { type = mode })
  return table.concat(lines, "\n")
end

local function search_replace(confirm, default_search)
  local opts = { prompt = "Search for: " }
  if default_search and default_search ~= "" then
    opts.default = default_search
  end
  vim.ui.input(opts, function(search)
    if not search or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(replacement)
      if replacement == nil then
        return
      end
      -- escape everything that is special in a :substitute command so the
      -- input is taken literally (no regex/backreferences); real newlines
      -- become \n so multi-line selections still match literally
      local pattern = vim.fn.escape(search, "/\\"):gsub("\n", "\\n")
      local rep = vim.fn.escape(replacement, "/\\&~")
      local flags = confirm and "gc" or "g"
      vim.cmd(("%%s/%s/%s/%s"):format(pattern, rep, flags))
    end)
  end)
end

local function search_replace_visual(confirm)
  -- exit Visual mode so the '< '> marks are set. Must be sent via feedkeys:
  -- vim.cmd("normal! <Esc>") does not reliably translate <Esc> to the Escape
  -- key and would type literal characters into the buffer.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", true)
  search_replace(confirm, get_visual_selection())
end

vim.keymap.set("n", "<leader>rr", function()
  search_replace(false)
end, { desc = "Search and replace (no confirm)" })

vim.keymap.set("n", "<leader>rc", function()
  search_replace(true)
end, { desc = "Search and replace (confirm)" })

vim.keymap.set("x", "<leader>rr", function()
  search_replace_visual(false)
end, { desc = "Search and replace selection (no confirm)" })

vim.keymap.set("x", "<leader>rc", function()
  search_replace_visual(true)
end, { desc = "Search and replace selection (confirm)" })
