# 从零开始搭建Neovim Java IDE开发环境

@[toc]

# 系统环境
理论上这套环境是支持跨平台的，macOS，Linux，Windows都支持。为了防止一些微小的差异，这里我把我的环境信息说明一下。
OS: Ubuntu 20.04 LTS x86_64
CPU: Intel Xeon E5-2680 v4 (2) @ 2.394GHz
![在这里插入图片描述](https://img-blog.csdnimg.cn/d53f8732f945458ba9e3cc498c6d85a8.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)

这是我云服务器上的环境，没有什么特别的。

# 准备工作
## 文件下载
为了方便大家，我把本文中用于的所有文件。都上传到网盘供大家使用。

链接: [https://pan.baidu.com/s/1ngwkOpclgLCKUW_YFX-WOg?pwd=g8fu](https://pan.baidu.com/s/1ngwkOpclgLCKUW_YFX-WOg?pwd=g8fu) 提取码: `g8fu` 

文件说明：
- nvim-linux64.tar.gz 是neovim0.61的安装包
- jdk-11.0.13_linux-x64_bin.tar.gz 是JDK的压缩包
- jdt-language-server-1.9.0-202203031534.tar.gz用于智能提示的插件

## 安装neovim 0.6以上版本
采用任意一种方法都可以，只有一个要求neovim版本要0.6以上。
通用方法：
直接从github官网下载
[https://github.com/neovim/neovim/releases](https://github.com/neovim/neovim/releases)

考虑到github比较慢，所以可以使用CSDN的镜像进行下载。
[https://gitcode.net/mirrors/neovim/neovim](https://gitcode.net/mirrors/neovim/neovim)

下载后安装示例：

```bash
##解压
tar -xvf nvim-linux64.tar.gz
mv nvim-linux64 /usr/local/
##创建软链接
ln -s /usr/local/nvim-linux64/bin/nvim /bin/nvim
```



# 下载解压jdt-language-server

下载jdt-language-server
不同版本下载导航
[https://download.eclipse.org/jdtls/milestones/?d](https://download.eclipse.org/jdtls/milestones/?d)
我最终下载的版本是：

[https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz](https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz)

以下我的路径是个人喜好，可以根据自己的实际情况修改保存路径：
```bash
#创建workspace目录，后面会用到
mkdir -p ~/.local/share/nvim/lsp/jdt-language-server/workspace/folder
cd ~/.local/share/nvim/lsp/jdt-language-server
# 下载jdt-language-server-xxxxx.tar.gz
wget https://download.eclipse.org/jdtls/milestones/1.9.0/jdt-language-server-1.9.0-202203031534.tar.gz
# 解压
tar -zxvf jdt-language-server-1.9.0-202203031534.tar.gz
```
我的目录结构如下图所示
![在这里插入图片描述](https://img-blog.csdnimg.cn/05d58a9c52c4458dbed9275a33e1ad83.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)


## 安装JDK11
JDK版本选择，这里有一个小坑，就是JDK的版本要选择JDK11及以上版本才行。因为就目前来看，JDK8使用的概率还是非常高的。

如果你使用JDK8，使用java文件会报如下的错误：
***Client 1 quit with exit code 1 and signal 0***

**推荐使用JDK11**，因为我实测JDK11是正常使用的，其他版本的JDK我没有一一测试。
我的版本信息如下：

```bash
java -version
java version "11.0.13" 2021-10-19 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.13+10-LTS-370)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.13+10-LTS-370, mixed mode)
```
环境变量设置参考：

```bash
export JAVA_HOME=/root/neovim-IDE-soft/jdk-11.0.13 							#JDK的主目录，建议使用JDK11，使用JDK8会报错
PATH=$PATH:$JAVA_HOME/bin
export JDTLS_HOME=$HOME/.local/share/nvim/lsp/jdt-language-server/ 			# 包含 plugin 和 configs 的目录，由jdt-language-server-xxx.tar.gz解压出的
export WORKSPACE=$HOME/.local/share/nvim/lsp/jdt-language-server/workspace/ # 不设置则默认是$HOME/workspace
```
## 安装curl git
curl git这两个软件，很多系统上默认安装了，我在这里提一下，因为在使用nvim安装插件时会用到，特别是git。

ubuntu中这样安装，其他系统安装方法自己百度。
```bash
apt-get install -y curl git
```

 
至此准备工作完成了✅

# neovim配置
## 插件安装
```bash
#创建nvim用到的目录
mkdir -p ~/.config/nvim/lua
#创建插件管理器的配置文件
nvim ~/.config/nvim/lua/plugins.lua
```
`~/.config/nvim/lua/plugins.lua`文件内容如下：

```lua
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

```
配置主配置文件：
```bash
nvim ~/.config/nvim/init.lua
```
添加内容如下：

```bash
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
-- tab=4个空格
vim.opt.tabstop=4
vim.opt.shiftwidth=4


```
保存后，重新打开nvim。执行`:PackerInstall`，如下图所示：
![在这里插入图片描述](https://img-blog.csdnimg.cn/c03e3e0a60d1490d9df3a166f9f13b84.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)
插件安装成功，界面如下：

![在这里插入图片描述](https://img-blog.csdnimg.cn/2e82bf4ff07b4899b03ab335e8ef8859.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)
这样我们就完成了，Java开发所需要的核心插件的安装了。
	 

```lua
-- Packer可以管理自己的更新
 	 use "wbthomason/packer.nvim"      
      --Nvim LSP 客户端的快速入门配置
      use "neovim/nvim-lspconfig"
      --自动提示插件
      use {
        "hrsh7th/nvim-cmp",
        requires = {
          "hrsh7th/cmp-nvim-lsp", --neovim 内置 LSP 客户端的 nvim-cmp 源
          "hrsh7th/cmp-buffer", --从buffer中智能提示
          "hrsh7th/cmp-path" --自动提示硬盘上的文件
        }
      }
	  -- 代码段提示
      use {
        "https://gitcode.net/mirrors/L3MON4D3/LuaSnip",
        requires = {
          "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
          "rafamadriz/friendly-snippets" --代码段合集
        }
      }

      -- java语言支持jdtls扩展插件，在lsp基础上扩展了一些实用的内容
      use "mfussenegger/nvim-jdtls"
      
```
## 配置nvim-cmp

```lua
#创建plugin配置目录
mkdir -p ~/.config/nvim/after/plugin
#编辑nvim-cmp配置文件
nvim  ~/.config/nvim/after/plugin/nvim-cmp.lua
```
~/.config/nvim/after/plugin/nvim-cmp.lua文件内容如下：

```lua
local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then
  return
end

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- luasnip setup
local luasnip = require "luasnip"

-- nvim-cmp setup
local cmp = require "cmp"
cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false
    },
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
      else
        fallback()
      end
    end
  },
  sources = {
    {name = "nvim_lsp"},
    {name = "luasnip"},
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    {name = "path"}
  }
}

```
## 配置LuaSnip

```lua
nvim ~/.config/nvim/after/plugin/snippets.lua
```
内容如下：

```lua
local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.

-- Every unspecified option will be set to the default.
ls.config.set_config({
	history = true,
	-- Update more often, :h events for more info.
	updateevents = "TextChanged,TextChangedI",
	-- Snippets aren't automatically removed if their text is deleted.
	-- `delete_check_events` determines on which events (:h events) a check for
	-- deleted snippets is performed.
	-- This can be especially useful when `history` is enabled.
	delete_check_events = "TextChanged",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "choiceNode", "Comment" } },
			},
		},
	},
	-- treesitter-hl has 100, use something higher (default is 200).
	ext_base_prio = 300,
	-- minimal increase in priority.
	ext_prio_increase = 1,
	enable_autosnippets = true,
	-- mapping for cutting selected text so it's usable as SELECT_DEDENT,
	-- SELECT_RAW or TM_SELECTED_TEXT (mapped via xmap).
	store_selection_keys = "<Tab>",
	-- luasnip uses this function to get the currently active filetype. This
	-- is the (rather uninteresting) default, but it's possible to use
	-- eg. treesitter for getting the current filetype by setting ft_func to
	-- require("luasnip.extras.filetype_functions").from_cursor (requires
	-- `nvim-treesitter/nvim-treesitter`). This allows correctly resolving
	-- the current filetype in eg. a markdown-code block or `vim.cmd()`.
	ft_func = function()
		return vim.split(vim.bo.filetype, ".", true)
	end,
})

-- args is a table, where 1 is the text in Placeholder 1, 2 the text in
-- placeholder 2,...
local function copy(args)
	return args[1]
end

-- 'recursive' dynamic snippet. Expands to some text followed by itself.
local rec_ls
rec_ls = function()
	return sn(
		nil,
		c(1, {
			-- Order is important, sn(...) first would cause infinite loop of expansion.
			t(""),
			sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
		})
	)
end

-- complicated function for dynamicNode.
local function jdocsnip(args, _, old_state)
	-- !!! old_state is used to preserve user-input here. DON'T DO IT THAT WAY!
	-- Using a restoreNode instead is much easier.
	-- View this only as an example on how old_state functions.
	local nodes = {
		t({ "/**", " * " }),
		i(1, "A short Description"),
		t({ "", "" }),
	}

	-- These will be merged with the snippet; that way, should the snippet be updated,
	-- some user input eg. text can be referred to in the new snippet.
	local param_nodes = {}

	if old_state then
		nodes[2] = i(1, old_state.descr:get_text())
	end
	param_nodes.descr = nodes[2]

	-- At least one param.
	if string.find(args[2][1], ", ") then
		vim.list_extend(nodes, { t({ " * ", "" }) })
	end

	local insert = 2
	for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
		-- Get actual name parameter.
		arg = vim.split(arg, " ", true)[2]
		if arg then
			local inode
			-- if there was some text in this parameter, use it as static_text for this new snippet.
			if old_state and old_state[arg] then
				inode = i(insert, old_state["arg" .. arg]:get_text())
			else
				inode = i(insert)
			end
			vim.list_extend(
				nodes,
				{ t({ " * @param " .. arg .. " " }), inode, t({ "", "" }) }
			)
			param_nodes["arg" .. arg] = inode

			insert = insert + 1
		end
	end

	if args[1][1] ~= "void" then
		local inode
		if old_state and old_state.ret then
			inode = i(insert, old_state.ret:get_text())
		else
			inode = i(insert)
		end

		vim.list_extend(
			nodes,
			{ t({ " * ", " * @return " }), inode, t({ "", "" }) }
		)
		param_nodes.ret = inode
		insert = insert + 1
	end

	if vim.tbl_count(args[3]) ~= 1 then
		local exc = string.gsub(args[3][2], " throws ", "")
		local ins
		if old_state and old_state.ex then
			ins = i(insert, old_state.ex:get_text())
		else
			ins = i(insert)
		end
		vim.list_extend(
			nodes,
			{ t({ " * ", " * @throws " .. exc .. " " }), ins, t({ "", "" }) }
		)
		param_nodes.ex = ins
		insert = insert + 1
	end

	vim.list_extend(nodes, { t({ " */" }) })

	local snip = sn(nil, nodes)
	-- Error on attempting overwrite.
	snip.old_state = param_nodes
	return snip
end

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function bash(_, _, command)
	local file = io.popen(command, "r")
	local res = {}
	for line in file:lines() do
		table.insert(res, line)
	end
	return res
end

-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local date_input = function(args, snip, old_state, fmt)
	local fmt = fmt or "%Y-%m-%d"
	return sn(nil, i(1, os.date(fmt)))
end

ls.snippets = {
	-- When trying to expand a snippet, luasnip first searches the tables for
	-- each filetype specified in 'filetype' followed by 'all'.
	-- If ie. the filetype is 'lua.c'
	--     - luasnip.lua
	--     - luasnip.c
	--     - luasnip.all
	-- are searched in that order.
	all = {
		-- trigger is `fn`, second argument to snippet-constructor are the nodes to insert into the buffer on expansion.
		s("fn", {
			-- Simple static text.
			t("//Parameters: "),
			-- function, first parameter is the function, second the Placeholders
			-- whose text it gets as input.
			f(copy, 2),
			t({ "", "function " }),
			-- Placeholder/Insert.
			i(1),
			t("("),
			-- Placeholder with initial text.
			i(2, "int foo"),
			-- Linebreak
			t({ ") {", "\t" }),
			-- Last Placeholder, exit Point of the snippet.
			i(0),
			t({ "", "}" }),
		}),
		s("class", {
			-- Choice: Switch between two different Nodes, first parameter is its position, second a list of nodes.
			c(1, {
				t("public "),
				t("private "),
			}),
			t("class "),
			i(2),
			t(" "),
			c(3, {
				t("{"),
				-- sn: Nested Snippet. Instead of a trigger, it has a position, just like insert-nodes. !!! These don't expect a 0-node!!!!
				-- Inside Choices, Nodes don't need a position as the choice node is the one being jumped to.
				sn(nil, {
					t("extends "),
					-- restoreNode: stores and restores nodes.
					-- pass position, store-key and nodes.
					r(1, "other_class", i(1)),
					t(" {"),
				}),
				sn(nil, {
					t("implements "),
					-- no need to define the nodes for a given key a second time.
					r(1, "other_class"),
					t(" {"),
				}),
			}),
			t({ "", "\t" }),
			i(0),
			t({ "", "}" }),
		}),
		-- Alternative printf-like notation for defining snippets. It uses format
		-- string with placeholders similar to the ones used with Python's .format().
		s(
			"fmt1",
			fmt("To {title} {} {}.", {
				i(2, "Name"),
				i(3, "Surname"),
				title = c(1, { t("Mr."), t("Ms.") }),
			})
		),
		-- To escape delimiters use double them, e.g. `{}` -> `{{}}`.
		-- Multi-line format strings by default have empty first/last line removed.
		-- Indent common to all lines is also removed. Use the third `opts` argument
		-- to control this behaviour.
		s(
			"fmt2",
			fmt(
				[[
			foo({1}, {3}) {{
				return {2} * {4}
			}}
			]],
				{
					i(1, "x"),
					rep(1),
					i(2, "y"),
					rep(2),
				}
			)
		),
		-- Empty placeholders are numbered automatically starting from 1 or the last
		-- value of a numbered placeholder. Named placeholders do not affect numbering.
		s(
			"fmt3",
			fmt("{} {a} {} {1} {}", {
				t("1"),
				t("2"),
				a = t("A"),
			})
		),
		-- The delimiters can be changed from the default `{}` to something else.
		s(
			"fmt4",
			fmt("foo() { return []; }", i(1, "x"), { delimiters = "[]" })
		),
		-- `fmta` is a convenient wrapper that uses `<>` instead of `{}`.
		s("fmt5", fmta("foo() { return <>; }", i(1, "x"))),
		-- By default all args must be used. Use strict=false to disable the check
		s(
			"fmt6",
			fmt("use {} only", { t("this"), t("not this") }, { strict = false })
		),
		-- Use a dynamic_node to interpolate the output of a
		-- function (see date_input above) into the initial
		-- value of an insert_node.
		s("novel", {
			t("It was a dark and stormy night on "),
			d(1, date_input, {}, { user_args = { "%A, %B %d of %Y" } }),
			t(" and the clocks were striking thirteen."),
		}),
		-- Parsing snippets: First parameter: Snippet-Trigger, Second: Snippet body.
		-- Placeholders are parsed into choices with 1. the placeholder text(as a snippet) and 2. an empty string.
		-- This means they are not SELECTed like in other editors/Snippet engines.
		ls.parser.parse_snippet(
			"lspsyn",
			"Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"
		),

		-- When wordTrig is set to false, snippets may also expand inside other words.
		ls.parser.parse_snippet(
			{ trig = "te", wordTrig = false },
			"${1:cond} ? ${2:true} : ${3:false}"
		),

		-- When regTrig is set, trig is treated like a pattern, this snippet will expand after any number.
		ls.parser.parse_snippet({ trig = "%d", regTrig = true }, "A Number!!"),
		-- Using the condition, it's possible to allow expansion only in specific cases.
		s("cond", {
			t("will only expand in c-style comments"),
		}, {
			condition = function(line_to_cursor, matched_trigger, captures)
				-- optional whitespace followed by //
				return line_to_cursor:match("%s*//")
			end,
		}),
		-- there's some built-in conditions in "luasnip.extras.expand_conditions".
		s("cond2", {
			t("will only expand at the beginning of the line"),
		}, {
			condition = conds.line_begin,
		}),
		-- The last entry of args passed to the user-function is the surrounding snippet.
		s(
			{ trig = "a%d", regTrig = true },
			f(function(_, snip)
				return "Triggered with " .. snip.trigger .. "."
			end, {})
		),
		-- It's possible to use capture-groups inside regex-triggers.
		s(
			{ trig = "b(%d)", regTrig = true },
			f(function(_, snip)
				return "Captured Text: " .. snip.captures[1] .. "."
			end, {})
		),
		s({ trig = "c(%d+)", regTrig = true }, {
			t("will only expand for even numbers"),
		}, {
			condition = function(line_to_cursor, matched_trigger, captures)
				return tonumber(captures[1]) % 2 == 0
			end,
		}),
		-- Use a function to execute any shell command and print its text.
		s("bash", f(bash, {}, "ls")),
		-- Short version for applying String transformations using function nodes.
		s("transform", {
			i(1, "initial text"),
			t({ "", "" }),
			-- lambda nodes accept an l._1,2,3,4,5, which in turn accept any string transformations.
			-- This list will be applied in order to the first node given in the second argument.
			l(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
		}),

		s("transform2", {
			i(1, "initial text"),
			t("::"),
			i(2, "replacement for e"),
			t({ "", "" }),
			-- Lambdas can also apply transforms USING the text of other nodes:
			l(l._1:gsub("e", l._2), { 1, 2 }),
		}),
		s({ trig = "trafo(%d+)", regTrig = true }, {
			-- env-variables and captures can also be used:
			l(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
		}),
		-- Set store_selection_keys = "<Tab>" (for example) in your
		-- luasnip.config.setup() call to populate
		-- TM_SELECTED_TEXT/SELECT_RAW/SELECT_DEDENT.
		-- In this case: select a URL, hit Tab, then expand this snippet.
		s("link_url", {
			t('<a href="'),
			f(function(_, snip)
				-- TM_SELECTED_TEXT is a table to account for multiline-selections.
				-- In this case only the first line is inserted.
				return snip.env.TM_SELECTED_TEXT[1] or {}
			end, {}),
			t('">'),
			i(1),
			t("</a>"),
			i(0),
		}),
		-- Shorthand for repeating the text in a given node.
		s("repeat", { i(1, "text"), t({ "", "" }), rep(1) }),
		-- Directly insert the ouput from a function evaluated at runtime.
		s("part", p(os.date, "%Y")),
		-- use matchNodes (`m(argnode, condition, then, else)`) to insert text
		-- based on a pattern/function/lambda-evaluation.
		-- It's basically a shortcut for simple functionNodes:
		s("mat", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, "%d", "contains a number", "no number :("),
		}),
		-- The `then`-text defaults to the first capture group/the entire
		-- match if there are none.
		s("mat2", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, "[abc][abc][abc]"),
		}),
		-- It is even possible to apply gsubs' or other transformations
		-- before matching.
		s("mat3", {
			i(1, { "sample_text" }),
			t(": "),
			m(
				1,
				l._1:gsub("[123]", ""):match("%d"),
				"contains a number that isn't 1, 2 or 3!"
			),
		}),
		-- `match` also accepts a function in place of the condition, which in
		-- turn accepts the usual functionNode-args.
		-- The condition is considered true if the function returns any
		-- non-nil/false-value.
		-- If that value is a string, it is used as the `if`-text if no if is explicitly given.
		s("mat4", {
			i(1, { "sample_text" }),
			t(": "),
			m(1, function(args)
				-- args is a table of multiline-strings (as usual).
				return (#args[1][1] % 2 == 0 and args[1]) or nil
			end),
		}),
		-- The nonempty-node inserts text depending on whether the arg-node is
		-- empty.
		s("nempty", {
			i(1, "sample_text"),
			n(1, "i(1) is not empty!"),
		}),
		-- dynamic lambdas work exactly like regular lambdas, except that they
		-- don't return a textNode, but a dynamicNode containing one insertNode.
		-- This makes it easier to dynamically set preset-text for insertNodes.
		s("dl1", {
			i(1, "sample_text"),
			t({ ":", "" }),
			dl(2, l._1, 1),
		}),
		-- Obviously, it's also possible to apply transformations, just like lambdas.
		s("dl2", {
			i(1, "sample_text"),
			i(2, "sample_text_2"),
			t({ "", "" }),
			dl(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
		}),
	},
	java = {
		-- Very long example for a java class.
		s("fn", {
			d(6, jdocsnip, { 2, 4, 5 }),
			t({ "", "" }),
			c(1, {
				t("public "),
				t("private "),
			}),
			c(2, {
				t("void"),
				t("String"),
				t("char"),
				t("int"),
				t("double"),
				t("boolean"),
				i(nil, ""),
			}),
			t(" "),
			i(3, "myFunc"),
			t("("),
			i(4),
			t(")"),
			c(5, {
				t(""),
				sn(nil, {
					t({ "", " throws " }),
					i(1),
				}),
			}),
			t({ " {", "\t" }),
			i(0),
			t({ "", "}" }),
		}),
	},
	tex = {
		-- rec_ls is self-referencing. That makes this snippet 'infinite' eg. have as many
		-- \item as necessary by utilizing a choiceNode.
		s("ls", {
			t({ "\\begin{itemize}", "\t\\item " }),
			i(1),
			d(2, rec_ls, {}),
			t({ "", "\\end{itemize}" }),
		}),
	},
}

-- autotriggered snippets have to be defined in a separate table, luasnip.autosnippets.
ls.autosnippets = {
	all = {
		s("autotrigger", {
			t("autosnippet"),
		}),
	},
}

-- in a lua file: search lua-, then c-, then all-snippets.
ls.filetype_extend("lua", { "c" })
-- in a cpp file: search c-snippets, then all-snippets only (no cpp-snippets!!).
ls.filetype_set("cpp", { "c" })

-- Beside defining your own snippets you can also load snippets from "vscode-like" packages
-- that expose snippets in json files, for example <https://github.com/rafamadriz/friendly-snippets>.
-- Mind that this will extend  `ls.snippets` so you need to do it after your own snippets or you
-- will need to extend the table yourself instead of setting a new one.

require("luasnip.loaders.from_vscode").load({ include = { "python" } }) -- Load only python snippets

-- The directories will have to be structured like eg. <https://github.com/rafamadriz/friendly-snippets> (include
-- a similar `package.json`)
require("luasnip.loaders.from_vscode").load({ paths = { "./my-snippets" } }) -- Load snippets from my-snippets folder

-- You can also use lazy loading so snippets are loaded on-demand, not all at once (may interfere with lazy-loading luasnip itself).
require("luasnip.loaders.from_vscode").lazy_load() -- You can pass { paths = "./my-snippets/"} as well

-- You can also use snippets in snipmate format, for example <https://github.com/honza/vim-snippets>.
-- The usage is similar to vscode.

-- One peculiarity of honza/vim-snippets is that the file with the global snippets is _.snippets, so global snippets
-- are stored in `ls.snippets._`.
-- We need to tell luasnip that "_" contains global snippets:
ls.filetype_extend("all", { "_" })

require("luasnip.loaders.from_snipmate").load({ include = { "c" } }) -- Load only python snippets

require("luasnip.loaders.from_snipmate").load({ path = { "./my-snippets" } }) -- Load snippets from my-snippets folder
-- If path is not specified, luasnip will look for the `snippets` directory in rtp (for custom-snippet probably
-- `~/.config/nvim/snippets`).

require("luasnip.loaders.from_snipmate").lazy_load() -- Lazy loading
```

## 配置nvim-jdtls
nvim-jdtls是java开发的核心组件了，可以说上面都算是环境准备，现在终于轮到它啦。

### 核心配置
要配置 nvim-jdtls, 添加以下内容 ftplugin/java.lua 在 neovim 配置基目录 (示例. `~/.config/nvim/ftplugin/java.lua`, 详情见 `:help base-directory`)。

```lua
mkdir -p ~/.config/nvim/ftplugin/
nvim ~/.config/nvim/ftplugin/java.lua
```
编辑文件，并且我的内容如下，请根据自己的实现情况调整。
主要就是文件的路径调整。

```lua
local config = {
  cmd = {
    "java",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
    "-configuration",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/config_linux",
    "-data",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/workspace/folder"
  },
  root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
  settings = {
    java = {}
  },
  init_options = {
    bundles = {}
  }
}
require("jdtls").start_or_attach(config)

```

> **小坑提醒：**
> org.eclipse.equinox.launcher`_1.6.400.v20210924-0641`.jar这个jar包的小版本号一直在变，不要忘记调整了，我之前就因为这个版本号浪费了好久排错。

为了方便大家理解每行配置的意思，我把配置做了注释，主要源于官方文档的翻译。
当心💀，它表示你必须调整一些东西。
```lua
-- 查看 `:help vim.lsp.start_client` 了解支持的 `config` 选项的概述。
local config = {
  	-- 启动语言服务器的命令
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {

    -- 💀
    'java', -- 或者绝对路径 '/path/to/java11_or_newer/bin/java'
            -- 取决于 `java` 是否在您的 $PATH 环境变量中以及它是否指向正确的版本。

    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

    -- 💀
    --'-jar', '/path/to/jdtls_install_location/plugins/org.eclipse.equinox.launcher_VERSION_NUMBER.jar',
           -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
           -- 必须指向                                                               修改这里为
           -- eclipse.jdt.ls 安装路径                                                实际版本

	'-jar', '/home/vnc/.local/share/nvim/lsp/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',

    -- 💀
    --'-configuration', '/path/to/jdtls_install_location/config_SYSTEM',
                      -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
                      -- Must point to the                      Change to one of `linux`, `win` or `mac`
                      -- eclipse.jdt.ls installation            Depending on your system.
    --这里是我们上面解压的jdt-language-server绝对路径，我这里是linux，请根据系统类型调整
	'-configuration', '/home/vnc/.local/share/nvim/lsp/jdt-language-server/config_linux',

    -- 💀
    -- 请参阅 README 中的“数据目录配置”部分
    '-data', '/home/vnc/.local/share/nvim/lsp/jdt-language-server/workspace/folder'
  },

  -- 💀
  -- 这是默认设置，如果未提供，您可以将其删除。 或根据需要进行调整。
  -- 每个唯一的 root_dir 将启动一个专用的 LSP 服务器和客户端
  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

  -- 这里可以配置eclipse.jdt.ls具体设置
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- 选项列表
  settings = {
    java = {
    }
  },

  -- Language server `initializationOptions`
  -- 您需要使用 jar 文件的路径扩展 `bundles`
  -- 如果你想使用额外的 eclipse.jdt.ls 插件。
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- 如果您不打算使用调试器或其他 eclipse.jdt.ls 插件，您可以删除它
  init_options = {
    bundles = {}
  },
}
-- 这将启动一个新的客户端和服务器，
-- 或根据 `root_dir` 附加到现有的客户端和服务器。
require('jdtls').start_or_attach(config)
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/f84364fbd293447da022a145a5d569d3.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)

### Lombok支持
使用过Spring Boot开发的工程师，对Lombok应该不陌生吧。这个小插件可以让我们的代码变的简洁。用了以后就回不去的插件。在IDEA中使用都是正常的，用vim开发显示不正常就很难受了。
如下图所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/cb676f13a3d84dbc922329375a842c4d.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)


```bash
cd /home/vnc/.local/share/nvim/lsp/jdt-language-server
#下载lombok.jar
wget https://projectlombok.org/downloads/lombok.jar
```
最终我们得到的路径是`/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar`

我们在-jar参数前面加入以下几行配置：

```bash
"-javaagent:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",
"-Xbootclasspath/a:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",
```
如下加粗部分
 "--add-opens",
"java.base/java.util=ALL-UNNAMED",
"--add-opens",
"java.base/java.lang=ALL-UNNAMED",
**<font color=green>"-javaagent:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",
"-Xbootclasspath/a:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",</font>**
"-jar",
"/home/vnc/.local/share/nvim/lsp/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",


一定要在-jar前面加，不然会出错。
参考：
[https://github.com/mfussenegger/nvim-jdtls/issues/28](https://github.com/mfussenegger/nvim-jdtls/issues/28)

完成以后不报错了，代码简洁。真舒服！！！
![在这里插入图片描述](https://img-blog.csdnimg.cn/3c009e397d724918a70759152c20e5e9.png?x-oss-process=image/watermark,type_d3F5LXplbmhlaQ,shadow_50,text_Q1NETiBASVRLRVlf,size_20,color_FFFFFF,t_70,g_se,x_16)
### 我的完整配置分享
每个人的使用习惯都不相同，我把常用的快捷键进行了映射，供大家参考。

- `<space>rn`变量重命名
- `<leader>f`代码格式化
- 保存自动格式化
- `<A-o>`自动导入全部缺失的包
等等。

我的配置文件：`nvim ~/.config/nvim/ftplugin/java.lua`
全部内容如下，仅大家参考：


```lua
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    --增加lombok插件支持，getter setter good bye
    "-javaagent:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",
    "-Xbootclasspath/a:/home/vnc/.local/share/nvim/lsp/jdt-language-server/lombok.jar",
    "-jar",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
    "-configuration",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/config_linux",
    "-data",
    "/home/vnc/.local/share/nvim/lsp/jdt-language-server/workspace/folder"
  },
  root_dir = require("jdtls.setup").find_root({".git", "mvnw", "gradlew"}),
  settings = {
    java = {}
  },
  init_options = {
    bundles = {}
  }
}
require("jdtls").start_or_attach(config)

local current_buff = vim.api.nvim_get_current_buf
-- 在语言服务器附加到当前缓冲区之后
-- 使用 on_attach 函数仅映射以下键
local java_on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  -- Mappings.
  local opts = {noremap = true, silent = true}
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  --buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  --buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap("n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<space>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  --重命名
  buf_set_keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  --智能提醒，比如：自动导包 已经用lspsaga里的功能替换了
  buf_set_keymap("n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  --buf_set_keymap('n', '<C-j>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap("n", "<S-C-j>", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
  --代码格式化
  buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  buf_set_keymap("n", "<leader>l", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  buf_set_keymap("n", "<leader>l", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  --自动导入全部缺失的包，自动删除多余的未用到的包
  buf_set_keymap("n", "<A-o>", "<cmd>lua require'jdtls'.organize_imports()<CR>", opts)
  --引入局部变量的函数 function to introduce a local variable
  buf_set_keymap("n", "crv", "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
  buf_set_keymap("v", "crv", "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
  --function to extract a constant
  buf_set_keymap("n", "crc", "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
  buf_set_keymap("v", "crc", "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)
  --将一段代码提取成一个额外的函数function to extract a block of code into a method
  buf_set_keymap("v", "crm", "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

  -- 代码保存自动格式化formatting
  vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
end

java_on_attach(nil, current_buff)

```


# CSDN博客地址
https://blog.csdn.net/lxyoucan/article/details/123453802
