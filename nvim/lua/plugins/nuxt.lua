return {
  -- 1. Import LazyVim's official Vue support
  -- This handles the "volar" setup and the complex paths that caused the crash
  { import = "lazyvim.plugins.extras.lang.vue" },

  -- 2. Import TypeScript support
  -- CRITICAL: Even if you write JS, Nuxt uses the TS engine (vtsls) to
  -- read the .nuxt/ folder and give you auto-imports.
  { import = "lazyvim.plugins.extras.lang.typescript" },

  -- 3. Slight tweak to ensure Volar knows about Nuxt
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.volar = opts.servers.volar or {}
      opts.servers.volar.init_options = opts.servers.volar.init_options or {}
      opts.servers.volar.init_options.vue = {
        hybridMode = true,
      }
    end,
  },
}
