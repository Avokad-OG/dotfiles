-- Smart pane navigation: C-h/j/k/l switches between nvim windows and,
-- at the edge, tmux panes. Requires the tmux bindings in ~/.config/tmux/tmux.conf.
return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = true,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    init = function()
      -- We define our own keymaps in config/keymaps.lua (loaded after LazyVim defaults)
      vim.g.tmux_navigator_no_mappings = true
    end,
  },
}
