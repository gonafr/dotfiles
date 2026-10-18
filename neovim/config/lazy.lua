local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." } },
			true,
			{}
		)
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = { -- add LazyVim and import its plugins
		{
			"LazyVim/LazyVim",
			import = "lazyvim.plugins",
		},
		-- import any extras modules here
		-- web development
		{ import = "lazyvim.plugins.extras.lang.typescript" },
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.lang.tailwind" },
		-- backend languages
		{ import = "lazyvim.plugins.extras.lang.java" },
		-- other languages
		{ import = "lazyvim.plugins.extras.lang.markdown" },
		{ import = "lazyvim.plugins.extras.lang.yaml" },
		-- linters and formatters
		{ import = "lazyvim.plugins.extras.formatting.prettier" },
		{ import = "lazyvim.plugins.extras.linting.eslint" },
		-- ai
		{ import = "lazyvim.plugins.extras.ai.copilot" },
		{ import = "lazyvim.plugins.extras.ai.copilot-chat" },
		-- ui
		{ import = "lazyvim.plugins.extras.ui.mini-animate" },
		{
			import = "lazyvim.plugins.extras.lang.java",
		},
		{
			"mason-org/mason.nvim",
			build = ":MasonUpdate",
			config = function()
				require("mason").setup()
			end,
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			dependencies = { "mason-org/mason.nvim" },
			config = function()
				require("mason-tool-installer").setup({
					ensure_installed = { "jdtls" },
					auto_update = false,
					run_on_start = true,
				})
			end,
		}, -- import/override with your plugins
		{
			import = "plugins",
		},
	},
	defaults = {
		-- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
		-- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
		lazy = false,
		-- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
		-- have outdated releases, which may break your Neovim install.
		version = false, -- always use the latest git commit
		-- version = "*", -- try installing the latest stable version for plugins that support semver
	},
	install = {
		colorscheme = { "tokyonight", "habamax" },
	},
	checker = {
		enabled = true, -- check for plugin updates periodically
		notify = false, -- notify on update
	}, -- automatically check for plugin updates
	performance = {
		rtp = {
			-- disable some rtp plugins
			disabled_plugins = {
				"gzip", -- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
