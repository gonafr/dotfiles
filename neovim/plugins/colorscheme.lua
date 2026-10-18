return {{
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("nord").setup({})
    end
}, {
    "LazyVim/LazyVim",
    opts = {
        colorscheme = "nord"
    }
}}
