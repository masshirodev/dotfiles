lvim.colorscheme = "kanagawa"
-- require('kanagawa').setup({
--   compile = true, -- enable compiling the colorscheme
--   -- undercurl = true, -- enable undercurls
--   commentStyle = { italic = false },
--   -- functionStyle = { italic = false },
--   -- keywordStyle = { italic = false },
--   -- typeStyle = { italic = false },
--   -- statementStyle = { italic = false },
--   -- overrides = function(colors)
--   --   return {
--   --     -- Assign a static color to strings
--   --     String = { fg = colors.palette.carpYellow, italic = false },
--   --     -- theme colors will update dynamically when you change theme!
--   --     SomePluginHl = { fg = colors.theme.syn.type, bold = true },
--   --     Italic = { italic = false },
--   --     Special = { italic = false },
--   --   }
--   -- end,
-- })

vim.opt.relativenumber = true

-- nvim transparent background
-- vim.api.nvim_set_option('termguicolors', true)
-- vim.api.nvim_command('hi Normal guibg=NONE ctermbg=NONE')
-- vim.api.nvim_command('hi NormalNC guibg=NONE ctermbg=NONE')
lvim.transparent_window = false

-- Change theme settings
-- lvim.builtin.theme.options.dim_inactive = true
-- lvim.builtin.theme.options.style = "storm"

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- GPC Syntax Highlighting (Kanagawa-matched colors)
local function setup_gpc_highlights()
  -- Kanagawa palette colors:
  local colors = {
    fujiWhite   = "#DCD7BA",  -- default text
    oldWhite    = "#C8C093",  -- light gray
    fujiGray    = "#727169",  -- comments/dim
    sumiInk     = "#1F1F28",  -- background
    waveBlue    = "#223249",  -- dark blue
    crystalBlue = "#7E9CD8",  -- functions
    springBlue  = "#7FB4CA",  -- types/combos
    springGreen = "#98BB6C",  -- strings
    oniViolet   = "#957FB8",  -- keywords
    sakuraPink  = "#D27E99",  -- numbers
    carpYellow  = "#E6C384",  -- variables
    roninYellow = "#FF9E3B",  -- constants/warnings
    surimiOrange= "#FFA066",  -- booleans
    autumnRed   = "#C34043",  -- logical ops
    waveAqua    = "#6A9589",  -- operators
  }

  -- Comments
  vim.api.nvim_set_hl(0, "gpcLineComment", { fg = colors.fujiGray, italic = true })
  vim.api.nvim_set_hl(0, "gpcBlockComment", { fg = colors.fujiGray, italic = true })
  vim.api.nvim_set_hl(0, "gpcTodo", { fg = colors.roninYellow, bold = true })

  -- Strings
  vim.api.nvim_set_hl(0, "gpcString", { fg = colors.springGreen })

  -- Keywords (if, else, while, for, return, etc.)
  vim.api.nvim_set_hl(0, "gpcKeyword", { fg = colors.oniViolet })
  vim.api.nvim_set_hl(0, "gpcDeclare", { fg = colors.oniViolet })
  vim.api.nvim_set_hl(0, "gpcStorage", { fg = colors.oniViolet })

  -- Types (int, uint8, string, etc.)
  vim.api.nvim_set_hl(0, "gpcType", { fg = colors.springBlue })

  -- Booleans (TRUE, FALSE)
  vim.api.nvim_set_hl(0, "gpcBoolean", { fg = colors.surimiOrange })

  -- Numbers
  vim.api.nvim_set_hl(0, "gpcNumber", { fg = colors.sakuraPink })

  -- Variables
  vim.api.nvim_set_hl(0, "gpcVariable", { fg = colors.carpYellow })
  vim.api.nvim_set_hl(0, "gpcVarDef", { fg = colors.roninYellow })

  -- Constants (after const/define)
  vim.api.nvim_set_hl(0, "gpcConstDef", { fg = colors.roninYellow, bold = true })

  -- Combos
  vim.api.nvim_set_hl(0, "gpcComboKeyword", { fg = colors.oniViolet })
  vim.api.nvim_set_hl(0, "gpcComboName", { fg = colors.springBlue, bold = true })

  -- Functions
  vim.api.nvim_set_hl(0, "gpcFunctionDef", { fg = colors.crystalBlue, bold = true })
  vim.api.nvim_set_hl(0, "gpcFunctionCall", { fg = colors.crystalBlue })

  -- Operators
  vim.api.nvim_set_hl(0, "gpcLogicalOp", { fg = colors.autumnRed, bold = true })
  vim.api.nvim_set_hl(0, "gpcCompareOp", { fg = colors.springBlue })
  vim.api.nvim_set_hl(0, "gpcMathOp", { fg = colors.springBlue })
  vim.api.nvim_set_hl(0, "gpcBitwiseOp", { fg = colors.springBlue })
  vim.api.nvim_set_hl(0, "gpcAssignOp", { fg = colors.springBlue })

  -- Delimiters
  vim.api.nvim_set_hl(0, "gpcDelimiter", { fg = colors.oldWhite })

  -- Preprocessor
  vim.api.nvim_set_hl(0, "gpcIncludeKeyword", { fg = colors.oniViolet })
  vim.api.nvim_set_hl(0, "gpcIncludeFile", { fg = colors.springGreen })
  vim.api.nvim_set_hl(0, "gpcPreProc", { fg = colors.oniViolet })
end

-- Apply on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = setup_gpc_highlights
})

-- Apply when opening GPC files (after syntax loads)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gpc",
  callback = setup_gpc_highlights
})

-- Apply on syntax set (catches all cases)
vim.api.nvim_create_autocmd("Syntax", {
  pattern = "gpc",
  callback = setup_gpc_highlights
})

-- Apply immediately
setup_gpc_highlights()
