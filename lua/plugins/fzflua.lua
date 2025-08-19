return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    enable = true,
    config = function()
      require("fzf-lua").setup({})
      -- Keymap here if you want
      vim.api.nvim_set_keymap(
        "n",
        "<Leader>fk",
        "<cmd>lua require('fzf-lua').keymaps()<CR>",
        { noremap = true, silent = true, desc = "Search Keymaps" }
      )
    end,
  },
  -- other plugins ...
}
