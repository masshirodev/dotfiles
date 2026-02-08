return {
  {
    url = "https://gitlab.com/masshirodev/gpc.nvim",
    ft = "gpc",
    dependencies = {
      {
        "zkiwiko/gpc-vscode",
        build = "npm install && npm run compile",
      },
    },
    build = "cd tree-sitter-gpc && npm install && npx tree-sitter generate",
    config = function()
      -- Server path is auto-detected from gpc-vscode dependency
      require("gpc").setup()
      -- Auto-install tree-sitter parser if nvim-treesitter is available
      if pcall(require, "nvim-treesitter") then
        vim.cmd("TSInstall! gpc")
      end
    end,
  }
}
