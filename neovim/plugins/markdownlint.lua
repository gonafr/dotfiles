-- Use a custom markdownlint config (e.g. longer MD013 line length)
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", vim.fn.stdpath("config") .. "/linters/.markdownlint.yaml", "--" },
        },
      },
    },
  },
}
