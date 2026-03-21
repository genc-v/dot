return {
  {
    "stevearc/conform.nvim",
    opts = {
      -- Only prettier for formatting, never eslint
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        vue = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        html = { "prettier" },
      },

      -- If formatter missing or fails → do nothing, no fallback to eslint
      format_on_save = {
        lsp_fallback = false,
        timeout_ms = 500,
      },

      stop_after_first = true,
    },
  },
}
