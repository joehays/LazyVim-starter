return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      -- Make sure LocalLeader is defined
      if vim.g.maplocalleader == nil then
        vim.g.maplocalleader = "\\"
      end

      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.qol.todo_items"] = {}, -- Enables todo lists
          ["core.dirman"] = {
            config = {
              workspaces = {
                ["org-joe"] = "~/notes/org-joe",
                ["org-tech"] = "~/notes/org-tech",
                ["org-scripture-power"] = "~/notes/org-scripture-power",
                ["norg-test"] = "~/norg-test",
              },
              default_workspace = "org-joe",
            },
          },

          -- Add these core modules for functionality
          ["core.esupports.hop"] = {}, -- For link navigation
          ["core.promo"] = {}, -- For list promotion/demotion

          ["core.keybinds"] = {
            config = {
              default_keybinds = false, -- Now disable default keybindings
              neorg_leader = "<LocalLeader>",
              hook = function(keybinds)
                -- Define your custom keybindings - starting with just todo items
                keybinds.map_event_to_mode("norg", "n", {
                  { "<LocalLeader>td", "core.qol.todo_items.todo.task-done" },
                  { "<LocalLeader>tu", "core.qol.todo_items.todo.task-undone" },
                  { "<LocalLeader>tp", "core.qol.todo_items.todo.task-pending" },
                  { "<LocalLeader>th", "core.qol.todo_items.todo.task-on_hold" },
                  { "<LocalLeader>tc", "core.qol.todo_items.todo.task-cancelled" },
                  { "<LocalLeader>tr", "core.qol.todo_items.todo.task-recurring" },
                  { "<LocalLeader>ti", "core.qol.todo_items.todo.task-important" },
                  { "<C-Space>", "core.qol.todo_items.todo.task-cycle" },
                  { "<CR>", "core.esupports.hop.hop-link" },
                  { "<Tab>", "core.promo.promote" },
                  { "<S-Tab>", "core.promo.demote" },
                })
                -- Log to verify keybindings are being set
                vim.notify("Neorg custom keybindings have been configured")
              end,
            },
          },
        },
      })

      -- Add a VimEnter autocmd to run the sync-parsers command after Neovim has fully started
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function()
            vim.cmd("Neorg sync-parsers")
          end, 1000) -- Wait 1 second after Vim starts
        end,
        once = true,
      })
    end,
  },
}
--[[
return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      -- Make sure LocalLeader is defined
      if vim.g.maplocalleader == nil then
        vim.g.maplocalleader = "\\"
      end
      
      -- Add debug print to check if LocalLeader is recognized correctly
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function()
            local localleader = vim.g.maplocalleader or "undefined"
            vim.notify("LocalLeader is currently set to: " .. vim.inspect(localleader), vim.log.levels.INFO, {timeout = 10000})
          end, 2000)
        end,
        once = true,
      })
      
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.concealer"] = {},
          ["core.qol.todo_items"] = {}, 
          ["core.dirman"] = {
            config = {
              workspaces = {
                ["org-joe"] = "~/notes/org-joe",
                ["org-tech"] = "~/notes/org-tech",
                ["org-scripture-power"] = "~/notes/org-scripture-power",
                ["norg-test"] = "~/norg-test",
              },
              default_workspace = "org-joe",
            },
          },
          ["core.esupports.hop"] = {},
          ["core.promo"] = {},
          
          ["core.keybinds"] = {
            config = {
              default_keybinds = true,  -- Enable default keybindings for debugging
              neorg_leader = "<LocalLeader>",
              hook = function(keybinds)
                -- Print debug info about keybinds
                vim.notify("Neorg keybinds hook is running", vim.log.levels.INFO, {timeout = 5000})
              end
            },
          },
        },
      })
      
      -- After Neorg is loaded, manually check what keybindings exist
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "norg",
        callback = function()
          vim.defer_fn(function()
            vim.notify("Norg filetype detected, checking keybindings...", vim.log.levels.INFO, {timeout = 5000})
            -- Try to run this command to check keybindings
            local ok, result = pcall(vim.cmd, "verbose map <LocalLeader>")
            if not ok then
              vim.notify("Could not check keybindings: " .. tostring(result), vim.log.levels.ERROR, {timeout = 10000})
            end
          end, 1000)
        end,
      })
      
      -- Add a VimEnter autocmd to run the sync-parsers command after Neovim has fully started
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function() 
            vim.cmd("Neorg sync-parsers")
          end, 1000)
        end,
        once = true,
      })
    end,
  },
}
]]

--[[
return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Make sure LocalLeader is defined
      if vim.g.maplocalleader == nil then
        vim.g.maplocalleader = "\\"
      end
      
      require("neorg").setup({
        load = {
          ["core.defaults"] = {},
          ["core.integrations.telescope"] = {},
          ["core.concealer"] = {},
          ["core.qol.todo_items"] = {}, -- Enables todo lists
          ["core.dirman"] = {
            config = {
              workspaces = {
                ["org-joe"] = "~/notes/org-joe",
                ["org-tech"] = "~/notes/org-tech",
                ["org-scripture-power"] = "~/notes/org-scripture-power",
                ["norg-test"] = "~/norg-test",
              },
              default_workspace = "org-joe",
            },
          },
          -- Add these missing modules
          ["core.integrations.treesitter"] = {},
          ["core.esupports.hop"] = {},  -- For link navigation
          ["core.promo"] = {},          -- For list promotion/demotion
          ["core.itero"] = {},          -- For list iterations
          
          ["core.dirman"] = {},
          ["core.keybinds"] = {
            config = {
              default_keybinds = false,  -- Disable default keybindings
              neorg_leader = "<LocalLeader>",
              hook = function(keybinds)
                  -- Define your custom keybindings
                  keybinds.map_event_to_mode("norg", {
                    n = { -- Normal mode
                      -- Todo items
                      { "<LocalLeader>td", "core.qol.todo_items.todo.task-done" },
                      { "<LocalLeader>tu", "core.qol.todo_items.todo.task-undone" },
                      { "<LocalLeader>tp", "core.qol.todo_items.todo.task-pending" },
                      { "<LocalLeader>th", "core.qol.todo_items.todo.task-on_hold" },
                      { "<LocalLeader>tc", "core.qol.todo_items.todo.task-cancelled" },
                      { "<LocalLeader>tr", "core.qol.todo_items.todo.task-recurring" },
                      { "<LocalLeader>ti", "core.qol.todo_items.todo.task-important" },
                      { "<C-Space>", "core.qol.todo_items.todo.task-cycle" },
                      { "<LocalLeader>tR", "core.qol.todo_items.todo.task-cycle-reverse" },
                      
                      -- Navigation
                      { "gj", "core.integrations.treesitter.next.heading" },
                      { "gk", "core.integrations.treesitter.previous.heading" },
                      { "] ]", "core.integrations.treesitter.next.heading" },
                      { "[[", "core.integrations.treesitter.previous.heading" },
                      
                      -- Lists
                      { "<Tab>", "core.promo.promote" },
                      { "<S-Tab>", "core.promo.demote" },
                      
                      -- Links
                      { "<CR>", "core.esupports.hop.hop-link" },
                      { "<LocalLeader>ln", "core.esupports.hop.hop-link" },
                    },
                    i = { -- Insert mode
                      -- Some useful insert mode bindings
                      { "<C-t>", "core.promo.promote" },
                      { "<C-d>", "core.promo.demote" },
                      { "<C-CR>", "core.itero.next-iteration" },
                    },
                    v = { -- Visual mode
                      -- Visual mode bindings
                      { "<Tab>", "core.promo.promote.range" },
                      { "<S-Tab>", "core.promo.demote.range" },
                    }
                  })
                  
                  -- Log to verify keybindings are being set
                  vim.notify("Neorg custom keybindings have been configured")
              end
            },
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
                      keybinds.map("norg", "n", leader .. "tR", "<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)") -- Custom binding for reverse cycle
                      keybinds.map("norg", "n", leader .. "t<Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)")
                  end
              }
          },
        },
      })
      
      -- Add a VimEnter autocmd to run the sync-parsers command after Neovim has fully started
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.defer_fn(function() 
            vim.cmd("Neorg sync-parsers")
          end, 1000)  -- Wait 1 second after Vim starts
        end,
        once = true,
      })
    end,
  },
}
]]

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

-- keybinds.map("norg", "n", "<C-Space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)")
