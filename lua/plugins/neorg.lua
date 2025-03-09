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
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
              },
            },
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
