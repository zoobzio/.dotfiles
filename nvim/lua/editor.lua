local icons = require("config.icons")
local Editor = {}

local function setup_vim()
	vim.opt.textwidth = 0
	vim.opt.title = true
	vim.opt.hidden = true
	vim.opt.nu = true
	vim.opt.rnu = true
	vim.opt.fillchars = { eob = " " }

	vim.opt.tabstop = 2
	vim.opt.shiftwidth = 2
	vim.opt.expandtab = true
	vim.opt.cursorline = true
	vim.opt.termguicolors = true
	vim.opt.background = "dark"

	vim.opt.completeopt = "menu,menuone,noinsert"
end

local function setup_theme()
	vim.cmd([[
    colorscheme gruvbox

    filetype plugin on

    hi Normal guibg=NONE
    hi NormalFloat guibg='#3c3836'
    hi SignColumn guibg='#3c3836'
    hi FloatBorder guifg='#3c3836'

    hi GitSignsAdd guibg='#3c3836' guifg='#b8bb26'
    hi GitSignsChange guibg='#3c3836' guifg='#fe8019'
    hi GitSignsDelete guibg='#3c3836' guifg='#fb4934'

    hi DiagnosticSignError guibg='#3c3836' guifg='#fb4934'
    hi DiagnosticSignWarn guibg='#3c3836' guifg='#fabd2f'
    hi DiagnosticSignHint guibg='#3c3836' guifg='#458588'
    hi DiagnosticSignInfo guibg='#3c3836' guifg='#83a598'
  ]])
end

local function setup_diagnostics()
	vim.diagnostic.config({
		virtual_text = false,
	})
	local signs = icons.diagnostics
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
	end
end

local function setup_formatter()
	local formatGroup = vim.api.nvim_create_augroup("FormatGroup", { clear = true })
	vim.api.nvim_create_autocmd(
		{ "BufWritePre" },
		{ pattern = "*.vue,*.ts,*.js,*.json,*.yaml,*.lua,*.go,*.py", command = "Neoformat", group = formatGroup }
	)
end

local function setup_shortcuts(shortcuts)
	for _, shortcut in pairs(shortcuts) do
		local options = { noremap = true, silent = true }
		if shortcut.opts then
			options = vim.tbl_extend("force", options, shortcut.opts)
		end
		vim.api.nvim_set_keymap(shortcut.mode, shortcut.expr, shortcut.cmd, options)
	end
end

function Editor.setup(shortcuts)
	setup_vim()
	setup_theme()
	setup_diagnostics()
	setup_formatter()
	setup_shortcuts(shortcuts)
end

return Editor
