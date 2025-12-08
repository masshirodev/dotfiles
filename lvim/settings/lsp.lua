-- ---@usage disable automatic installation of servers
lvim.lsp.installer.setup.automatic_installation = false

-- lvim.lsp.automatic_configuration.skipped_servers = { "csharp_ls" }
--
lvim.lsp.installer.setup.ensure_installed = {
  "tsserver",
  "eslint",
  "tailwindcss"
}

lvim.lsp.automatic_configuration.skipped_servers = {
  "denols",
  "vtsls",
  "rome",
  "ember",
  "glint"
}
require 'lspconfig'.lua_ls.setup {}
