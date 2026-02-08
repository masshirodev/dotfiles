return {
  "rcarriga/nvim-notify",
  config = function()
    local has_plugin, plg = pcall(require, "notify")
    if not has_plugin then
      return
    end

    plg.setup({
      fps = 60,
      stages = "fade_in_slide_out",
      timeout = 3000,
      background_colour = "NormalFloat",
      top_down = false,
      max_width = 50,
    })

    -- Override highlight groups to change colors
    vim.api.nvim_set_hl(0, "NotifyINFOBorder", { fg = "#333B47" })
    vim.api.nvim_set_hl(0, "NotifyINFOTitle", { fg = "#333B47" })
    vim.api.nvim_set_hl(0, "NotifyINFOIcon", { fg = "#333B47" })

    vim.notify = plg
  end,
}
