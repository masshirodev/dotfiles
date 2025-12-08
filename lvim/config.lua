--[[
lvim is the global options object
]]

--  @NOTE: All settings and plugins have their own file now (either /settings or /plugins)

-- Additional Plugins
lvim.plugins = {
  "nvim-lua/plenary.nvim", -- Needed to autoload files from /plugins
}

-- Settings
local function load_settings(directory)
  local scan_dir = require('plenary.scandir')
  local setting_files = scan_dir.scan_dir(directory, { depth = 1, search_pattern = "%.lua$" })

  for _, file in ipairs(setting_files) do
    dofile(file)
  end
end

load_settings(vim.fn.stdpath('config') .. '/settings')

-- Plugins
local function load_plugin_extensions(directory)
  local plugins = {}
  local scan_dir = require('plenary.scandir')
  local plugin_files = scan_dir.scan_dir(directory, { depth = 1, search_pattern = "%.lua$" })

  for _, file in ipairs(plugin_files) do
    local f = assert(loadfile(file))
    local plugin_list = f()
    for _, plugin in ipairs(plugin_list) do
      table.insert(plugins, plugin)
    end
  end

  return plugins
end

local plugin_extensions = load_plugin_extensions(vim.fn.stdpath('config') .. '/plugins')
for _, plugin in ipairs(plugin_extensions) do
  table.insert(lvim.plugins, plugin)
end

-- Plugin Settings
local function load_settings(directory)
  local scan_dir = require('plenary.scandir')
  local setting_files = scan_dir.scan_dir(directory, { depth = 1, search_pattern = "%.lua$" })

  for _, file in ipairs(setting_files) do
    dofile(file)
  end
end

load_settings(vim.fn.stdpath('config') .. '/settings/plugins')
