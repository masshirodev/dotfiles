lvim.builtin.lualine.style = "default"
lvim.builtin.lualine.options.theme = "horizon"
lvim.builtin.lualine.sections.lualine_b = { "lsp_progress" }

--  @BUG: Rip
-- table.insert(lvim.builtin.lualine.sections.lualine_x, "require'tabnine.status'.status()")
