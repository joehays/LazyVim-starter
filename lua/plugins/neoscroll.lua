return {
  "karb94/neoscroll.nvim",
  config = function()
    require("neoscroll").setup({
      -- Keys to be mapped to their corresponding default scrolling animation
      mappings = {
        "<C-u>",
        "<C-d>",
        "<C-b>",
        "<C-f>",
        "<C-y>",
        "<C-e>",
        "zt",
        "zz",
        "zb",
      },
      hide_cursor = true, -- Hide cursor while scrolling
      stop_eof = true, -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      duration_multiplier = 1.0, -- Global duration multiplier
      easing = "sine", -- Default easing function, {linear, quadratic, cubic, quartic, quintic, circular, sine}
      pre_hook = nil, -- Function to run before the scrolling animation starts
      post_hook = nil, -- Function to run after the scrolling animation ends
      performance_mode = false, -- Disable "Performance Mode" on all buffers.
      ignored_events = { -- Events ignored while scrolling
        "WinScrolled",
        "CursorMoved",
      },
    })
  end,
}

--[[
return {
  -- This is the plugin specification
  "karb94/neoscroll.nvim",
  -- 'opts' is the table that gets passed to the setup function
  -- In this case, we'll use a 'config' function for more complex setup
  opts = {},
  config = function()
    local neoscroll = require("neoscroll")

    -- Setup the plugin with default options
    neoscroll.setup({
      -- Default easing function
      easing = "quadratic",
    })

    -- Define and set the keymaps
    local keymap = {
      ["<C-u>"] = function()
        neoscroll.ctrl_u({ duration = 250, easing = "sine" })
      end,
      ["<C-d>"] = function()
        neoscroll.ctrl_d({ duration = 250, easing = "sine" })
      end,
      ["<C-b>"] = function()
        neoscroll.ctrl_b({ duration = 450, easing = "circular" })
      end,
      ["<C-f>"] = function()
        neoscroll.ctrl_f({ duration = 450, easing = "circular" })
      end,
      ["<C-y>"] = function()
        neoscroll.scroll(-0.1, { move_cursor = false, duration = 100 })
      end,
      ["<C-e>"] = function()
        neoscroll.scroll(0.1, { move_cursor = false, duration = 100 })
      end,
    }

    local modes = { "n", "v", "x" }
    for key, func in pairs(keymap) do
      vim.keymap.set(modes, key, func)
    end
  end,
}
]]
