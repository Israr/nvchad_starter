return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "github/copilot.vim",
    lazy = false,
    init = function()
      -- vim.g.copilot_node_command = "/usr/local/bin/node"
      -- Mapping tab is already used by NvChad
      -- vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      -- vim.g.copilot_tab_fallback = ""
      -- The mapping is set to other key, see custom/lua/mappings
      -- or run <leader>ch to see copilot mapping section
    end,
    config = function()
      require("mappings").copilot()
    end,
  },
  { "ethanholz/nvim-lastplace", config = function()
    require 'nvim-lastplace'.setup {}
  end,
    lazy = false
  },
  {
    "smoka7/hop.nvim",
    version = "*",
    event = "BufRead",
    opts = {
        keys = 'etovxqpdygfblzhckisuran'
    },
    config = function()
      require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      require("mappings").hop()
    end,
  },
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}

