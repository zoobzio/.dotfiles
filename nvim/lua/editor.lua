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

-- TODO the hex codes here should be variables stored somewhere
local function setup_theme()
	vim.cmd([[
    colorscheme cyberdream

    filetype plugin on

    hi Normal guibg=NONE
    hi NormalFloat guibg='#1e2124'
    hi SignColumn guibg='#1e2124'
    hi FloatBorder guifg='#1e2124'

    hi GitSignsAdd guibg='#1e2124' guifg='#5eff6c'
    hi GitSignsChange guibg='#1e2124' guifg='#ffbd5e'
    hi GitSignsDelete guibg='#1e2124' guifg='#ff6e5e'

    hi DiagnosticSignError guibg='#1e2124' guifg='#ff6e5e'
    hi DiagnosticSignWarn guibg='#1e2124' guifg='#ffbd5e'
    hi DiagnosticSignHint guibg='#1e2124' guifg='#5ef1ff'
    hi DiagnosticSignInfo guibg='#1e2124' guifg='#ff5ef1' 
  ]])
end

local function setup_diagnostics()
	-- Signs are configured through vim.diagnostic.config (sign_define is deprecated).
	-- texthl defaults to DiagnosticSign<Severity>, which the hi commands above style.
	local signs = icons.diagnostics
	local S = vim.diagnostic.severity
	vim.diagnostic.config({
		virtual_text = false,
		signs = {
			text = {
				[S.ERROR] = signs.Error,
				[S.WARN] = signs.Warn,
				[S.HINT] = signs.Hint,
				[S.INFO] = signs.Info,
			},
			numhl = {
				[S.ERROR] = "",
				[S.WARN] = "",
				[S.HINT] = "",
				[S.INFO] = "",
			},
		},
	})
end

local function setup_formatter()
	local formatGroup = vim.api.nvim_create_augroup("FormatGroup", { clear = true })
	vim.api.nvim_create_autocmd(
		{ "BufWritePre" },
		-- JS/TS/JSON/YAML/Vue are formatted by the oxfmt LSP (see plugins/lsp.lua)
		{ pattern = "*.lua,*.go,*.py", command = "Neoformat", group = formatGroup }
	)
  vim.api.nvim_create_autocmd(
    {"BufRead", "BufNewFile"},
    {
      pattern = "*.sqlx",
      callback = function()
        vim.bo.filetype = "sql"
      end,
    }
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
