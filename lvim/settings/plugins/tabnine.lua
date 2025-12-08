--lvim.builtin.cmp.formatting.source_names["tabnine"] = "(Tabnine)"
--table.insert(lvim.builtin.cmp.sources, 1, { name = "tabnine" })

--lvim.keys.insert_mode["<M-e>"] = nil
--lvim.keys.insert_mode["<A-e>"] = nil

--require('tabnine').setup({
--  disable_auto_comment = true,
--  accept_keymap = "<A-e>",
--  dismiss_keymap = "<C-]>",
--  debounce_ms = 800,
--  suggestion_color = { gui = "#808080", cterm = 244 },
--  exclude_filetypes = { "TelescopePrompt", "NvimTree", "Neotree" },
--  log_file_path = "/home/masshiro/tabnine.txt",
--})

--local cmp = require "cmp"
--local completion = require("tabnine.completion")
--local state = require("tabnine.state")

--lvim.builtin.cmp.mapping["<A-e>"] = function(fallback)
--  cmp.mapping.abort()
--  local tabnine_keys = "<A-e>"
--  if tabnine_keys ~= "" then
--    if not state.completions_cache then return tabnine_keys end
--    vim.schedule(completion.accept)
--  else
--    fallback()
--  end
--end
