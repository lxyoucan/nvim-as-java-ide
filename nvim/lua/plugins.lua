---@diagnostic disable: undefined-global
--在没有安装packer的电脑上，自动安装packer插件
local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system(
    {"git", "clone", "--depth", "1", "https://gitcode.net/mirrors/wbthomason/packer.nvim", install_path}
  ) --csdn加速镜像
  vim.cmd "packadd packer.nvim"
end
-- Only required if you have packer configured as `opt`
--【国内加速】插件名称超长的说明：
--由于国内网络环境访问github及其不稳定，所以如果在gitcode.net上的镜像的（https://gitcode.net/mirrors/开头的），我们尽量使用。这样可以提高访问速度。
--gitcode.net没有镜像的部分(https://gitcode.net/lxyoucan开头的),是我手动clone到gitcode上的不定期更新。
--如果你访问github比较流畅，插件名称只保留后两段即如：neovim/nvim-lspconfig
vim.cmd [[packadd packer.nvim]]
return require("packer").startup(function()
      -- Packer可以管理自己的更新
      use "https://gitcode.net/mirrors/wbthomason/packer.nvim"      
      --Nvim LSP 客户端的快速入门配置
      use "https://gitcode.net/mirrors/neovim/nvim-lspconfig"
      --自动提示插件
      use {
        "https://gitcode.net/mirrors/hrsh7th/nvim-cmp",
        requires = {
          "https://gitcode.net/lxyoucan/cmp-nvim-lsp", --neovim 内置 LSP 客户端的 nvim-cmp 源
          "https://gitcode.net/lxyoucan/cmp-buffer", --从buffer中智能提示
          "https://gitcode.net/lxyoucan/cmp-path" --自动提示硬盘上的文件
        }
      }
      -- java语言支持
      use "https://gitcode.net/lxyoucan/nvim-jdtls.git"
      -- 代码段提示
      use {
        "https://gitcode.net/mirrors/L3MON4D3/LuaSnip",
        requires = {
          "https://gitcode.net/lxyoucan/cmp_luasnip", -- Snippets source for nvim-cmp
          "https://gitcode.net/lxyoucan/friendly-snippets" --代码段合集
        }
      }
      --主题安装
      use "https://gitcode.net/mirrors/sainnhe/gruvbox-material"
end)


