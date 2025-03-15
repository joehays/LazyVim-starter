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
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
            },
          },
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

--[[
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    lazy = false,
    version = "*",
    opts = {
        load = {
            ["core.defaults"] = {}, -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.dirman"] = { -- Manages Neorg workspaces
                config = {
                    workspaces = {
                        notes = "~/notes",
                    },
                    default_workspace = "notes",
                },
            },
        },
    },
    dependencies = {
        { "nvim-lua/plenary.nvim", 
          "nvim-treesitter/nvim-treesitter",
      },
    },
  }, 
]]




  -- {
  --     "nvim-neorg/neorg",
  --     lazy = false,
  --     version = "*",
  --     config = function()
  --       require("neorg").setup {
  --         load = {
  --           ["core.defaults"] = {},
  --           ["core.concealer"] = {},
  --           ["core.dirman"] = {
  --             config = {
  --               workspaces = {
  --                 notes = "~/notes",
  --               },
  --               default_workspace = "notes",
  --             },
  --           },
  --         },
  --       }
  --       vim.wo.foldlevel = 99
  --       vim.wo.conceallevel = 2
  --     end,
  -- },

--  {
--    "nvim-neorg/neorg",
--    lazy = false,
--    version = "*",
--    config = true,
--    dependencies = {
--      "nvim-lua/plenary.nvim",
--    },
--  },


-- return {
--   {
--     "nvim-neorg/neorg",
--     lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
--     version = "*", -- Pin Neorg to the latest stable release
--     config = true,
--   },
-- }
