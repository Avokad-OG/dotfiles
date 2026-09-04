-- Smart pane navigation: C-h/j/k/l cross nvim windows and, at the edge,
-- tmux panes. Cross-into-tmux also needs matching prefix bindings on the
-- tmux side; without them navigation stops at the nvim window edge.
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
      -- Disable the plugin's default bindings; the C-h/j/k/l keymaps are
      -- bound separately so the nvim+tmux edge logic sits in one mapping set.
      vim.g.tmux_navigator_no_mappings = true
    end,
  },
}
