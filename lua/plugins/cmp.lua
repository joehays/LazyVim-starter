return {
  {
    "hrsh7th/nvim-cmp",
    enabled = true,  -- Force enable
    lazy = false,    -- Prevent lazy loading
    priority = 1000, -- Load this before other plugins
    -- Add a basic setup so we know it's loading
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({}),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
        }),
      })
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    enabled = true,
    lazy = false,
    after = "nvim-cmp", -- Load after nvim-cmp
  },
}

--[[
return {
  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    -- This is the main completion engine
    enabled = true,
    lazy = false,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = { "hrsh7th/nvim-cmp" },
    -- This is the LSP source for nvim-cmp
  },
}

]]
