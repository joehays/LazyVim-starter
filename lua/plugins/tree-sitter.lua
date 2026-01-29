return {
  -- Tree-sitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate", -- This command will be run after installation to update parsers
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "toml",
        "python",
        "bash",
        "rust",
        -- Add norg here. Make sure the parser is available.
        -- If 'norg' isn't found by TSUpdate, you might need to
        -- manually add it to the 'tree-sitter' CLI's grammar list or
        -- install it through a specific Neovim plugin if available.
        "norg",
      },
      sync_install = false, -- Install parsers asynchronously
      auto_install = true, -- Automatically install missing parsers
      highlight = {
        enable = true,
        -- Disable highlight for large files to improve performance
        disable = { "html" }, -- Example: disable html highlight for very large files
      },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          -- You can add your own custom textobjects here
          lookasides = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            -- ... other textobjects
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- Add jumps in the jumplist
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
            ["]C"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
            ["[C"] = "@class.outer",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- Add the norg parser manually if auto_install doesn't pick it up
      -- This part might be crucial for 'norg' if it's not a standard parser.
      -- You might need to find the specific Tree-sitter grammar for norg
      -- and ensure it's in a location where nvim-treesitter can find it,
      -- or that 'TSUpdate' can fetch it.
      -- Example: If the norg grammar is in a specific repository:
      -- require("nvim-treesitter.install").compilers.norg = {
      --   url = "https://github.com/nvim-neorg/tree-sitter-norg", -- Example URL
      --   files = { "src/parser.c", "src/scanner.c" },
      --   branch = "main",
      -- }
      -- You would then run `:TSInstall norg` after this.
    end,
  },

  --[[
  -- Neorg (if you're using Neorg and want its full features, including Tree-sitter integration)
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    ft = "norg",
    lazy = false, -- Load Neorg eagerly if you use it extensively
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/notes",
              work = "~/work-notes",
            },
            default_workspace = "notes",
          },
        },
        ["core.integrations.treesitter"] = {
          config = {
            -- Enable Tree-sitter for Neorg. This usually happens automatically
            -- if nvim-treesitter is set up correctly.
          },
        },
        -- Add other Neorg modules as needed
      },
    },
  } 
]]
}
