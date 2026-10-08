-- Vymrland "cyan" theme for Neovim, using Omarchy's generic aether.nvim.
-- Colors mirror colors.toml.
return {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#0d1117",
        dark_bg = "#090c10",
        darker_bg = "#05070a",
        lighter_bg = "#161b22",

        fg = "#c9d1d9",
        dark_fg = "#6e7681",
        light_fg = "#b0c4c4",
        bright_fg = "#e6edf3",
        muted = "#5f8787",

        red = "#ff6b6b",
        yellow = "#e3b341",
        orange = "#f0883e",
        green = "#7ee787",
        cyan = "#39c5cf",
        blue = "#58a6ff",
        magenta = "#bc8cff",
        brown = "#8b6c42",

        bright_red = "#ff7b72",
        bright_yellow = "#f2cc60",
        bright_green = "#9be89b",
        bright_cyan = "#56d4dd",
        bright_blue = "#79c0ff",
        bright_magenta = "#d2a8ff",

        accent = "#39c5cf",
        cursor = "#e6edf3",
        foreground = "#c9d1d9",
        background = "#0d1117",
        selection = "#2d4f4f",
        selection_foreground = "#c9d1d9",
        selection_background = "#2d4f4f",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
