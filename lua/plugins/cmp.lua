return {}
--[[
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    version = "*",
    config = true,
  },
}
]]
--[[
    config = function()
      local cmp = require("nvim-cmp")
      cmp.setup({
      ]]
--[[
    require("nvim-cmp").setup({
        sources = {
--          { name = "neorg" }, -- Add neorg as a source
          { name = "nvim_lsp" }, -- Add LSP completion if you're using it
          { name = "buffer" },   -- Add buffer completion
          { name = "path" },     -- Add path completion
          -- You can add other sources here as needed
        },
        --[[
        -- Other nvim-cmp settings (e.g., keymaps, formatting)
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })
    --end,
  },
}
        ]]
