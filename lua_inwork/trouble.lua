return {
  {
    "folke/trouble.nvim",
    enabled = not vim.g.disable_trouble, -- Example condition
    opts = { use_diagnostic_signs = true },
  },
}
