return {
  {
    "ojroques/nvim-osc52",
    config = function()
      local osc52 = require("osc52")
      vim.keymap.set("v", "<leader>y", osc52.copy_visual, { desc = "yank to system clipboard" })
      -- TODO: add this to the LazyVim menu
      -- TODO: add cut_visual keybindings as well
    end,
  },
}
