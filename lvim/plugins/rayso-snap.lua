return {
  {
    "masshirodev/rayso-snap.nvim",
    init = function()
      require 'raysosnap'.setup({
        theme = 'midnight',
        background = 'true',
        darkMode = 'true',
        padding = '16',
        language = 'auto'
      })
    end,
  }
}
