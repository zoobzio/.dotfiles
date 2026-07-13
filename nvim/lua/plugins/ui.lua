local icons = require("config.icons")

return {
	-- theme
	--"gruvbox-community/gruvbox",
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      italic_comments = true,
    }
  },

	-- icons
	"kyazdani42/nvim-web-devicons",

	-- ui improvements
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			-- replaces vim.ui.input (fixes telescope-file-browser focus bug)
			input = { enabled = true },
			-- replaces vim.ui.select
			picker = { enabled = true },
		},
	},

	-- notifications
	--[[{]]
		--[["rcarriga/nvim-notify",]]
		--[[opts = {]]
			--[[render = "wrapped-compact",]]
			--[[icons = {]]
				--[[DEBUG = icons.diagnostics.Debug,]]
				--[[ERROR = icons.diagnostics.Error,]]
				--[[INFO = icons.diagnostics.Info,]]
				--[[TRACE = icons.diagnostics.Trace,]]
				--[[WARN = icons.diagnostics.Warn,]]
			--[[},]]
			--[[timeout = 3000,]]
			--[[max_height = function()]]
				--[[return math.floor(vim.o.lines * 0.75)]]
			--[[end,]]
			--[[max_width = function()]]
				--[[return math.floor(vim.o.columns * 0.75)]]
			--[[end,]]
			--[[on_open = function(win)]]
				--[[vim.api.nvim_win_set_config(win, { zindex = 100 })]]
			--[[end,]]
		--[[},]]
		--[[init = function()]]
			--[[vim.notify = require("notify")]]
		--[[end,]]
	--[[},]]
}
