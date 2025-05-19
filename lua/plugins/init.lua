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
  {
    "ethanholz/nvim-lastplace",
    config = function()
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
      require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      require("mappings").hop()
    end,
  },
  {
    "cappyzawa/trim.nvim",
    event = "BufWritePre",
    config = function()
      require("trim").setup({})
    end
  },
  {
    "machakann/vim-highlightedyank",
    event = "TextYankPost",
    config = function()
      -- Configure vim-highlightedyank
      vim.g.highlightedyank_highlight_duration = 100 -- duration in milliseconds
    end,
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      }
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
  },
  {
    'RRethy/vim-illuminate',
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      picker = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          -- wo = { wrap = true } -- Wrap notifications
        }
      }
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader>ss",  function() Snacks.picker.smart() end,                                   desc = "Smart Find Files" },
      { "<leader>sb",  function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>s:",  function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>se",  function() Snacks.explorer() end,                                       desc = "File Explorer" },
      { "<leader>sfc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>sfg", function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>sff", function() Snacks.picker.files() end,                                   desc = "Find Files" },
      { "<leader>sfp", function() Snacks.picker.projects() end,                                desc = "Projects" },
      { "<leader>sfr", function() Snacks.picker.recent() end,                                  desc = "Recent" },

      { "<leader>sl",  function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sB",  function() Snacks.picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      { "<leader>sg",  function() Snacks.picker.grep() end,                                    desc = "Grep" },
      { "<leader>sh",  function() Snacks.picker.help() end,                                    desc = "Help Pages" },
      { "<leader>sp",  function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
      { "<leader>sq",  function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
    }
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,  -- This disables nvim-tree
  },

  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("chatgpt").setup()
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim", -- optional
  --     "nvim-telescope/telescope.nvim"
  --   }
  -- },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

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
