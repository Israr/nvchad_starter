-- BrightScript Debug Adapter Protocol (DAP) Configuration
-- Requires: nvim-dap plugin (https://github.com/mfussenegger/nvim-dap)
--
-- Usage:
--   require('rokucode.dap').setup()
--   Press <F5> to start debugging

local M = {}

-- Configuration defaults
M.config = {
  -- Debug adapter port (RokuCode debug server)
  port = 8081,

  -- Default Roku device IP (can be overridden per-launch)
  default_host = '192.168.1.100',

  -- Environment variable for password (avoids prompting)
  password_env = 'ROKU_DEV_PASSWORD',

  -- Keybindings (set to false to disable)
  keybindings = {
    continue = '<F5>',
    step_over = '<F10>',
    step_into = '<F11>',
    step_out = '<F12>',
    toggle_breakpoint = '<leader>b',
    conditional_breakpoint = '<leader>B',
    terminate = '<leader>dt',
    repl = '<leader>dr',
  },
}

-- Setup function
-- @param user_config table|nil Configuration overrides
function M.setup(user_config)
  -- Merge user config
  if user_config then
    M.config = vim.tbl_deep_extend('force', M.config, user_config)
  end

  -- Check for nvim-dap
  local ok, dap = pcall(require, 'dap')
  if not ok then
    vim.notify('[RokuCode] nvim-dap not found. Install it for debugging support.',
      vim.log.levels.WARN)
    return
  end

  -- Register BrightScript adapter
  M.setup_adapter(dap)

  -- Register configurations
  M.setup_configurations(dap)

  -- Register keybindings
  M.setup_keybindings(dap)

  vim.notify('BrightScript DAP configured. Press <F5> to debug.', vim.log.levels.INFO)
end

-- Setup debug adapter
function M.setup_adapter(dap)
  -- The RokuCode debug adapter runs as a server on port 8081
  -- It implements the Debug Adapter Protocol over binary socket
  dap.adapters.brightscript = {
    type = 'server',
    host = '127.0.0.1',
    port = M.config.port,
  }
end

-- Setup debug configurations
function M.setup_configurations(dap)
  dap.configurations.brightscript = {
    -- Launch configuration
    {
      type = 'brightscript',
      request = 'launch',
      name = 'Launch Roku App',
      -- Path to Roku app root (contains manifest)
      rootDir = '${workspaceFolder}',
      -- Roku device settings
      host = function()
        return vim.fn.input('Roku IP: ', M.config.default_host)
      end,
      password = function()
        -- Read from environment variable or prompt
        local env_password = os.getenv(M.config.password_env)
        if env_password and env_password ~= '' then
          return env_password
        end
        return vim.fn.inputsecret('Roku password: ')
      end,
      -- Stop on entry (optional)
      stopOnEntry = false,
      -- Inject helpers (BrightScript debugger protocol)
      injectRunLoop = true,
      -- Console output
      consoleOutput = 'normal',
    },

    -- Attach configuration
    {
      type = 'brightscript',
      request = 'attach',
      name = 'Attach to Roku App',
      host = function()
        return vim.fn.input('Roku IP: ', M.config.default_host)
      end,
      password = function()
        local env_password = os.getenv(M.config.password_env)
        if env_password and env_password ~= '' then
          return env_password
        end
        return vim.fn.inputsecret('Roku password: ')
      end,
    },
  }
end

-- Setup keybindings
function M.setup_keybindings(dap)
  local keybindings = M.config.keybindings

  -- Continue/Start
  if keybindings.continue then
    vim.keymap.set('n', keybindings.continue, function()
      dap.continue()
    end, { desc = 'DAP: Continue/Start' })
  end

  -- Step over
  if keybindings.step_over then
    vim.keymap.set('n', keybindings.step_over, function()
      dap.step_over()
    end, { desc = 'DAP: Step Over' })
  end

  -- Step into
  if keybindings.step_into then
    vim.keymap.set('n', keybindings.step_into, function()
      dap.step_into()
    end, { desc = 'DAP: Step Into' })
  end

  -- Step out
  if keybindings.step_out then
    vim.keymap.set('n', keybindings.step_out, function()
      dap.step_out()
    end, { desc = 'DAP: Step Out' })
  end

  -- Toggle breakpoint
  if keybindings.toggle_breakpoint then
    vim.keymap.set('n', keybindings.toggle_breakpoint, function()
      dap.toggle_breakpoint()
    end, { desc = 'DAP: Toggle Breakpoint' })
  end

  -- Conditional breakpoint
  if keybindings.conditional_breakpoint then
    vim.keymap.set('n', keybindings.conditional_breakpoint, function()
      dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end, { desc = 'DAP: Conditional Breakpoint' })
  end

  -- Terminate
  if keybindings.terminate then
    vim.keymap.set('n', keybindings.terminate, function()
      dap.terminate()
    end, { desc = 'DAP: Terminate' })
  end

  -- REPL
  if keybindings.repl then
    vim.keymap.set('n', keybindings.repl, function()
      dap.repl.open()
    end, { desc = 'DAP: Open REPL' })
  end
end

-- Helper: Check if debug server is running
function M.is_server_running()
  local handle = io.popen('lsof -i :' .. M.config.port .. ' 2>/dev/null')
  if handle then
    local result = handle:read('*a')
    handle:close()
    return result ~= ''
  end
  return false
end

-- Helper: Start debug server (if not running)
function M.ensure_server()
  if not M.is_server_running() then
    vim.notify('Starting RokuCode debug server...', vim.log.levels.INFO)
    vim.fn.jobstart('rokucode debug server', {
      detach = true,
    })
    -- Wait a moment for server to start
    vim.cmd('sleep 500m')
  end
end

return M
