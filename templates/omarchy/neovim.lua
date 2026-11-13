-- Bell Labs — load the bundled colourscheme from the active Omarchy theme.
return {
  {
    dir = vim.fn.expand("~/.config/omarchy/current/theme/nvim"),
    name = "bell-labs",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "bell-labs" },
  },
}
