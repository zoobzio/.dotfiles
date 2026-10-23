return {
	{
		"neovim/nvim-lspconfig",
		config = function(_, _)
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Applied to every server (merged with the per-server configs below).
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			vim.lsp.config("ts_ls", {
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = "/usr/lib/node_modules/@vue/typescript-plugin",
							languages = { "javascript", "typescript", "vue" },
						},
					},
				},
				filetypes = {
					"javascript",
					"typescript",
					"vue",
				},
			})

			-- Server definitions ship with nvim-lspconfig.
			-- oxfmt / oxlint prefer the project's node_modules/.bin binary and only
			-- attach when a project config (.oxfmtrc.json / .oxlintrc.json / package.json) is found.
			vim.lsp.enable({
				"ts_ls",
				"vue_ls",
				"pyright",
				"gopls",
				"lua_ls",
				"oxfmt",
				"oxlint",
			})

			-- format on save via the oxfmt server
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.name == "oxfmt" then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = args.buf,
							callback = function()
								vim.lsp.buf.format({ bufnr = args.buf, name = "oxfmt", timeout_ms = 2000 })
							end,
						})
					end
				end,
			})
		end,
	},
	{
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		opts = {},
	},
}
