return {
  {
    "nvim-neorg/neorg",
    --enabled = false,
    --lazy = false, -- Disable lazy loading as some `lazy.nvim` distributions set `lazy = true` by default
    event = "FileType norg",
    --version = "*", -- Pin Neorg to the latest stable release
    --version = "main",
    version = "87242d45",
    -- dependencies = { "hrsh7th/nvim-cmp", },
    dependencies = { "benlubas/neorg-interim-ls", "nvim-treesitter/nvim-treesitter" }, -- Essential for blink-cmp compatibility

    -- config = true,
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {
            config = {},
          },
          ["core.autocommands"] = {},
          ["core.clipboard"] = {},
          ["core.completion"] = {
            config = {
              --engine = "nvim-cmp",
              engine = { module_name = "external.lsp-completion" }, -- Use interim-ls
            },
          },
          ["core.concealer"] = {
            config = {
              icon_preset = "varied",
            },
          },
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
                my_other_notes = "~/work/notes",
              },
              default_workspace = "notes",
              index = "index.norg",
            },
          },
          ["core.dirman.utils"] = {
            config = {},
          },
          ["core.export"] = {
            config = {},
          },
          ["core.export.markdown"] = {
            config = {},
          },
          ["core.fs"] = {},
          ["core.highlights"] = {
            config = {},
          },
          --          ["core.integration.image"] = {
          --            config = {},
          --          },
          -- ["core.integrations.treesitter"] = {
          --   config = {
          --     -- Enable Tree-sitter for Neorg. This usually happens automatically
          --     -- if nvim-treesitter is set up correctly.
          --   },
          -- },
          --          ["core.latex.renderer"] = {
          --            config = {
          --                conceal = true,
          --                render_on_enter = true,
          --            },
          --          },
          ["core.neorgcmd"] = {
            config = {},
          },
          ["core.neorgcmd.commands.return"] = {},
          --          ["core.presenter"] = {
          --            config = {},
          --          },
          ["core.queries.native"] = {},
          ["core.storage"] = {
            config = {},
          },
          ["core.summary"] = {
            config = {},
          },
          ["core.syntax"] = {
            config = {},
          },
          ["core.tempus"] = {},
          ["core.text-objects"] = {
            config = {},
          },
          ["core.ui"] = {},
          ["external.interim-ls"] = {
            config = {
              -- default config shown
              completion_provider = {
                -- Enable or disable the completion provider
                enable = true,
                -- Show file contents as documentation when you complete a file name
                documentation = true,
                -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
                categories = false,
                -- suggest heading completions from the given file for `{@x|}` where `|` is your cursor
                -- and `x` is an alphanumeric character. `{@name}` expands to `[name]{:$/people:# name}`
                people = {
                  enable = true,
                  -- path to the file you're like to use with the `{@x` syntax, relative to the
                  -- workspace root, without the `.norg` at the end.
                  -- ie. `folder/people` results in searching `$/folder/people.norg` for headings.
                  -- Note that this will change with your workspace, so it fails silently if the file
                  -- doesn't exist
                  path = "people",
                },
              },
            },
          },
        },
      })
    end,
  },
}
