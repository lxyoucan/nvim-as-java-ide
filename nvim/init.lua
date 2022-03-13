--插件管理器
require("plugins")
--主题设置
vim.cmd("colorscheme " .. "gruvbox-material")
------按键映射 start------
local opts = {noremap = true, silent = true}
local keymap = vim.api.nvim_set_keymap
--把空格键设置成<leader>
vim.g.mapleader = " "
--快速跳转行首与行尾  
keymap('n', 'L', '$', opts)
keymap('v', 'L', '$', opts)
keymap('n', 'H', '^', opts)
keymap('v', 'H', '^', opts)
--插入模式jk当Esc 
keymap('i', 'jk', '<Esc>', opts)
--保 存
keymap('n', '<C-s>', ':w<CR>', opts)
keymap('i', '<C-s>', '<ESC> :w<CR>', opts)
--全选
keymap('n', '<C-a>', 'gg<S-v>G', opts)
------按键映射 end  ------
-- 文件编码格式
vim.opt.fileencoding = "utf-8"
-- 显示行号
vim.opt.number=true
-- tab=5个空格
vim.opt.tabstop=5
vim.opt.shiftwidth=5



