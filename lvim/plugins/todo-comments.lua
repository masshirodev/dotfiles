return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keywords = {
        OKAY = {
          icon = " ",
          color = "okay",
          alt = { "OK", "OKAY" },
        },
      },
      colors = {
        okay = { "Identifier", "#76FFCD" }
      }
    }
  }
}
