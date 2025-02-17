return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        -- Customize options here (optional)
        size = 20, -- Default terminal size
        open_mapping = [[<leader>\]], -- Keybinding to toggle the terminal 
        direction = "float", -- "horizontal" or "vertical"
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        close_on_exit = true,
        if string.match(shell_cmd, "zsh") then
          shell_cmd = shell_cmd .. " -l -i"  -- Add -l and -i for zsh
        elseif string.match(shell_cmd, "bash") then
          shell_cmd = shell_cmd .. " --login -i" -- Add --login and -i for bash
        else
          shell_cmd = shell_cmd .. " -i" -- Add -i for other shells (might not source rc files)
        end,
        float_opts = {
        	border = "curved",
        	winblend = 0,
        	highlights = {
        		border = "Normal",
        		background = "Normal",
        		},
        	},
      })
    end,
  },
}
-- shell = vim.o.shell,


--function _G.set_terminal_keymaps()
--  local opts = {noremap = true}
--  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
--  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
--  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
--  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
--  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
--  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
--end
--
--vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
--
--local Terminal = require("toggleterm.terminal").Terminal
--local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })
--
--function _LAZYGIT_TOGGLE()
--	lazygit:toggle()
--end
--
--local node = Terminal:new({ cmd = "node", hidden = true })
--
--function _NODE_TOGGLE()
--	node:toggle()
--end
--
--local ncdu = Terminal:new({ cmd = "ncdu", hidden = true })
--
--function _NCDU_TOGGLE()
--	ncdu:toggle()
--end
--
--local htop = Terminal:new({ cmd = "htop", hidden = true })
--
--function _HTOP_TOGGLE()
--	htop:toggle()
--end
--
--local python = Terminal:new({ cmd = "python", hidden = true })
--
--function _PYTHON_TOGGLE()
--	python:toggle()
--end
