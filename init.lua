-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- define LEADER keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- specify fonts to use
vim.o.guifont = "FiraCodeNerdFontMono-Regular:h12" -- Replace "Fira Code:h12" with your chosen font and size
--vim.o.guifont = "FiraCodeNerdFont-Regular:h12"

-- Set the NVIM_LISTEN_ADDRESS for the current session.
-- This makes the integrated terminal aware of the nvim server socket.
vim.g.serveraddr = "/tmp/nvim"
vim.env.NVIM_LISTEN_ADDRESS = vim.g.serveraddr

--vim.o.guifontwidth = auto -- Adjust font width automatically
--vim.o.guifontheight = auto -- Adjust font height automatically

-- opts.rocks.hererocks = true -- REALLY JUSTT NEED TO FIX LAROCKA

--[[
import = "lazyvim.plugins.extras.lang.typescript"

-- use mini.starter instead of alpha
import = "lazyvim.plugins.extras.ui.mini-starter"

-- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
import = "lazyvim.plugins.extras.lang.json"
]]

-- make clipboard integration easier!
-- vim.opt.clipboard = "unnamedplus"
