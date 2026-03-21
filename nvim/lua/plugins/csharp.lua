return {
  -- 1. The Roslyn Plugin
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      -- strict mode ensures it crashes if it can't find the SDK (good for debugging)
    },
  },

  -- 2. Add the Custom Registry to Mason
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- Ensure the registries list exists
      opts.registries = opts.registries or {
        "github:mason-org/mason-registry",
      }

      -- Add the "Crashdummyy" registry (this is where Roslyn lives)
      -- We put it first so it checks there first
      table.insert(opts.registries, 1, "github:Crashdummyy/mason-registry")
    end,
  },
  {
    "MoaidHathot/dotnet.nvim",
    cmd = "DotnetUI",
    opts = {},
  },
  -- {
  --   "GustavEikaas/easy-dotnet.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  --   config = function()
  --     local dotnet = require("easy-dotnet")
  --     dotnet.setup({
  --       -- Optional: Enable "Rider-like" features
  --       test_runner = {
  --         viewmode = "float",
  --       },
  --     })
  --   end,
  -- },
  {
    "smoka7/hop.nvim",
    version = "*",
    opts = {
      keys = "etovxqpdygfblzhckisuran",
    },
  },
}
