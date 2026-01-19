-- BrightScript LSP Configuration for Neovim
-- Add this to your Neovim config (e.g., ~/.config/nvim/lua/rokucode/lsp.lua)
--
-- For nvim-lspconfig users: This module registers BrightScript as a custom server.
-- Requires RokuCode CLI to be installed (via install.sh or manually).

local M = {}

-- Find rokucode CLI using same logic as VSCode extension
-- Searches common install locations even if not in PATH
local function find_rokucode()
  -- Check ROKUCODE_PATH env var first
  local env_path = os.getenv("ROKUCODE_PATH")
  if env_path and vim.fn.executable(env_path) == 1 then
    return env_path
  end

  -- Check ROKUCODE_BINARY env var (alternate name used by VSCode)
  local env_binary = os.getenv("ROKUCODE_BINARY")
  if env_binary and vim.fn.executable(env_binary) == 1 then
    return env_binary
  end

  -- Search common install locations (match VSCode exactly)
  local home = os.getenv("HOME")
  local paths = {
    home .. "/.bun/bin/rokucode",
    home .. "/.local/bin/rokucode",
    "/opt/homebrew/bin/rokucode", -- Homebrew on M1/M2 Macs
    "/usr/local/bin/rokucode",
    "/usr/bin/rokucode",
  }

  for _, path in ipairs(paths) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Fallback to PATH
  if vim.fn.executable("rokucode") == 1 then
    return "rokucode"
  end

  return nil
end

-- Configuration defaults
M.config = {
  -- Enable auto-setup (set to false to configure manually)
  auto_setup = true,

  -- LSP command (auto-detected, override if needed)
  cmd = nil, -- Will be set by find_rokucode()

  -- BrightScript LSP settings
  settings = {
    brightscript = {
      diagnostics = {
        enable = true,
      },
      hover = {
        enable = true,
      },
      completion = {
        enable = true,
      },
    },
  },
}

-- Setup function - call from your init.lua
-- @param user_config table|nil User configuration overrides
function M.setup(user_config)
  -- Merge user config
  if user_config then
    M.config = vim.tbl_deep_extend('force', M.config, user_config)
  end

  -- Auto-detect rokucode CLI if not explicitly set
  if not M.config.cmd then
    local rokucode_path = find_rokucode()
    if not rokucode_path then
      vim.notify('[RokuCode] rokucode CLI not found. Install via ./install.sh or set ROKUCODE_PATH',
        vim.log.levels.WARN)
      return
    end
    M.config.cmd = { rokucode_path, 'lsp', 'start' }
  end

  -- Register filetype detection for BrightScript
  M.setup_filetypes()

  -- Setup LSP if auto_setup is enabled
  if M.config.auto_setup then
    M.setup_lsp()
  end
end

-- Register BrightScript filetype detection
function M.setup_filetypes()
  vim.filetype.add({
    extension = {
      brs = 'brightscript',
    },
    pattern = {
      -- Match SceneGraph XML files in Roku projects
      ['.*%.xml'] = {
        priority = -math.huge, -- Low priority, let other plugins detect XML first
        function(path, bufnr)
          -- Only treat as BrightScript XML if it's in a Roku project
          local content = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false)
          for _, line in ipairs(content) do
            if line:match('component.*extends') or line:match('SceneGraph') then
              return 'xml' -- BrightScript SceneGraph XML
            end
          end
        end,
      },
    },
  })
end

-- Setup LSP using nvim-lspconfig
function M.setup_lsp()
  -- Check for nvim-lspconfig
  local ok, lspconfig = pcall(require, 'lspconfig')
  if not ok then
    vim.notify('[RokuCode] nvim-lspconfig not found. Install it or set auto_setup = false',
      vim.log.levels.WARN)
    return
  end

  local configs = require('lspconfig.configs')
  local util = require('lspconfig.util')

  -- Only register if not already registered
  if not configs.brightscript then
    configs.brightscript = {
      default_config = {
        cmd = M.config.cmd,
        filetypes = { 'brightscript', 'brs', 'xml' },
        root_dir = function(fname)
          -- Find workspace root by looking for common Roku project markers
          return util.root_pattern(
            'manifest',     -- Roku app manifest (always present)
            '.git',         -- Git repository root
            '.rokucode',    -- RokuCode config directory
            '.opencode',    -- OpenCode config directory
            'source',       -- Common BrightScript source directory
            'components'    -- SceneGraph components directory
          )(fname) or util.path.dirname(fname)
        end,
        single_file_support = true,
        settings = M.config.settings,
      },
      docs = {
        description = [[
BrightScript Language Server for Roku development.

Requires RokuCode CLI to be installed:
  https://github.com/Roku/rokucode

Install via:
  ./install.sh

Or manually:
  bun install && bun run build
  ln -s $(pwd)/packages/opencode/dist/@roku/rokucode-*/bin/rokucode ~/.local/bin/rokucode
]],
        default_config = {
          root_dir = [[root_pattern("manifest", ".git", ".rokucode", "source", "components")]],
        },
      },
    }
  end

  -- Setup the LSP
  lspconfig.brightscript.setup({
    on_attach = M.on_attach,
    capabilities = M.get_capabilities(),
    flags = {
      debounce_text_changes = 150,
    },
    settings = M.config.settings,
  })
end

-- Default on_attach handler
-- Override by passing custom on_attach in setup()
function M.on_attach(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Keybindings (standard LSP mappings)
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- Navigation
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

  -- Workspace
  vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)

  -- Code actions
  vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)

  -- Formatting
  vim.keymap.set('n', '<leader>f', function()
    vim.lsp.buf.format({ async = true })
  end, bufopts)

  -- Diagnostics navigation
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, bufopts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, bufopts)

  -- Notify user
  vim.notify('BrightScript LSP attached', vim.log.levels.INFO)
end

-- Get LSP capabilities
-- Integrates with nvim-cmp if available
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Try to enhance with nvim-cmp capabilities
  local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

-- Auto-format on save (optional - disabled by default)
-- Call this after setup() to enable
function M.enable_format_on_save()
  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.brs' },
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
end

return M
