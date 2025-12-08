lvim.colorscheme = "kanagawa"
require('kanagawa').setup({
  compile = true, -- enable compiling the colorscheme
  -- undercurl = true, -- enable undercurls
  commentStyle = { italic = false },
  -- functionStyle = { italic = false },
  -- keywordStyle = { italic = false },
  -- typeStyle = { italic = false },
  -- statementStyle = { italic = false },
  -- overrides = function(colors)
  --   return {
  --     -- Assign a static color to strings
  --     String = { fg = colors.palette.carpYellow, italic = false },
  --     -- theme colors will update dynamically when you change theme!
  --     SomePluginHl = { fg = colors.theme.syn.type, bold = true },
  --     Italic = { italic = false },
  --     Special = { italic = false },
  --   }
  -- end,
})

vim.opt.relativenumber = true

-- nvim transparent background
-- vim.api.nvim_set_option('termguicolors', true)
-- vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
-- vim.api.nvim_command('hi NormalNC guibg=NONE ctermbg=NONE')
lvim.transparent_window = true

-- Change theme settings
-- lvim.builtin.theme.options.dim_inactive = true
-- lvim.builtin.theme.options.style = "storm"

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false
