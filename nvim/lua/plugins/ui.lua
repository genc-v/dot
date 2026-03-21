return {
  -- 1. TRANSPARENCY (Make background same as terminal)
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true, -- This enables the transparency
      styles = {
        sidebars = "transparent", -- Make the file tree transparent
        floats = "transparent", -- Make popup windows transparent
      },
    },
  },

  -- 2. DISABLE ANIMATIONS

  -- Disable the "Smooth Cursor" animations (mini.animate)
  { "echasnovski/mini.animate", enabled = false },

  -- Disable Smooth Scrolling (Snacks)
  -- LazyVim now uses Snacks for scrolling, this turns it off for instant jumps
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },

  -- 3. OPTIONAL: RESTORE CLASSIC CMD LINE
  -- LazyVim uses "Noice" (the fancy floating command line in the middle).
  -- If you want the command line back at the BOTTOM like standard Vim (no animations):
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        bottom_search = true, -- Search line at the bottom
        command_palette = false, -- No floating box for commands
        long_message_to_split = true,
      },
      -- Stop the message popup from sliding in
      lsp = {
        progress = { enabled = false }, -- Disable the "LSP loading" spinner animation
      },
    },
  },
}
