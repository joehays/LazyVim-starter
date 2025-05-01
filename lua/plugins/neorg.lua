return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    build = ":Neorg sync-parsers",
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.qol.todo_items"] = {}, -- Enables todo lists
          ["core.dirman"] = {},
          ["core.keybinds"] = {
              config = {
                  hook = function(keybinds)
                      local leader = "<LocalLeader>"
                      keybinds.map("norg", "n", leader .. "td", "<Plug>(neorg.qol.todo-items.todo.task-done)")
                      keybinds.map("norg", "n", leader .. "tu", "<Plug>(neorg.qol.todo-items.todo.task-undone)")
                      keybinds.map("norg", "n", leader .. "tp", "<Plug>(neorg.qol.todo-items.todo.task-pending)")
                      keybinds.map("norg", "n", leader .. "th", "<Plug>(neorg.qol.todo-items.todo.task-on_hold)")
                      keybinds.map("norg", "n", leader .. "tc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)")
                      keybinds.map("norg", "n", leader .. "tr", "<Plug>(neorg.qol.todo-items.todo.task-recurring)")
                      keybinds.map("norg", "n", leader .. "ti", "<Plug>(neorg.qol.todo-items.todo.task-important)")
                      keybinds.map("norg", "n", "<C-Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)")
                      keybinds.map("norg", "n", leader .. "tR", "<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)") -- Custom binding for reverse cycle
                  end
              }
          },
        },
      })
    end,
  },
}
