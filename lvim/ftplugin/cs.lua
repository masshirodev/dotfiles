local lsp_manager = require "lvim.lsp.manager"
local util = require("lspconfig").util

local function custom_root_dir(fname)
  local current_dir = vim.fs.dirname(fname)
  while current_dir and current_dir ~= "/" do
    if vim.fn.fnamemodify(current_dir, ":t") == "api" then
      local sln = vim.fs.find(function(name)
        return name:match('%.sln$')
      end, {
        path = current_dir,
        limit = 1,
        type = 'file'
      })[1]

      if sln then
        return current_dir
      end
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end
  return util.root_pattern("*.sln", "*.csproj")(fname)
end

lsp_manager.setup("omnisharp", {
  cmd = {
    "omnisharp",
    "--languageserver",
    "--hostPID",
    tostring(vim.fn.getpid()),
    "--encoding",
    "utf-8",
    "--enable-package-restore",
    "--msbuild-sdks-path=/usr/share/dotnet/sdk/6.0.135/Sdks",
    "--assembly-loader=coreclr",  -- Force using .NET Core
    "--disable-static-file-codemodel", -- Add this
    "--force-restore",                 -- Add this
    "--enable-decompilation",          -- Add this
    "--enable-roslyn-analyzers",
    "-s",                              -- Find .sln file
    (function()
      local root = custom_root_dir(vim.api.nvim_buf_get_name(0))
      local sln = vim.fs.find(function(name)
        return name:match('%.sln$')
      end, {
        path = root,
        type = 'file'
      })[1]
      return sln or ""
    end)()
  },
  root_dir = custom_root_dir,
  enable_roslyn_analyzers = true,
  enable_import_completion = true,
  organize_imports_on_format = true,
  sdk_include_prereleases = true,
  analyze_open_documents_only = false,
  enable_editorconfig_support = true,
  enable_ms_build_load_projects_on_demand = false,
  enable_package_auto_restore = true,
  on_attach = function(client, bufnr)
    print("OmniSharp attached to buffer: " .. bufnr)
    print("Root directory: " .. client.config.root_dir)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Force a solution reload
    vim.defer_fn(function()
      client.request('o#reloadSolution', {}, function(err, result)
        if err then
          print('Error reloading solution: ' .. vim.inspect(err))
        else
          print('Solution reloaded successfully')
        end
      end)
    end, 1000)
  end,
})
