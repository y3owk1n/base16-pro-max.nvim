vim.env.NVIM_TESTING = "1"

vim.opt.rtp:prepend(vim.fn.getcwd())

require("base16-pro-max").setup()
