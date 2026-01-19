-- RokuCode Terminal Integration for Neovim
-- Provides :RokuCode command to open AI chat in terminal
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │  DEPRECATED: This module is deprecated.                                 │
-- │  Use require("rokucode").setup() instead for full integration.          │
-- │                                                                         │
-- │  Migration:                                                             │
-- │    -- Old:                                                              │
-- │    require("rokucode-terminal").setup()                                 │
-- │                                                                         │
-- │    -- New:                                                              │
-- │    require("rokucode").setup({                                          │
-- │      provider = { enabled = "terminal" },                               │
-- │    })                                                                   │
-- │                                                                         │
-- │  The new plugin provides:                                               │
-- │    - Context injection (@this, @buffer, @diagnostics, etc.)             │
-- │    - Server auto-detection                                              │
-- │    - SSE events (auto-reload, permissions)                              │
-- │    - Multiple providers (snacks, kitty, wezterm, tmux)                  │
-- │    - Statusline integration                                             │
-- └─────────────────────────────────────────────────────────────────────────┘
--
-- Usage (legacy):
--   require('rokucode-terminal').setup()
--   :RokuCode              -- Open RokuCode in configured mode
--   :RokuCodeTab           -- Open RokuCode in new tab
--   :RokuCodeSplit         -- Open RokuCode in horizontal split
--   :RokuCodeVsplit        -- Open RokuCode in vertical split

local M = {}

-- Emit deprecation warning once per session
local warned = false
local function warn_deprecated()
  if warned then
    return
  end
  warned = true
  vim.schedule(function()
    vim.notify(
      "[rokucode-terminal] DEPRECATED: Use require('rokucode').setup() instead.\n"
        .. "See :help rokucode for migration guide.",
      vim.log.levels.WARN
    )
  end)
end

-- Configuration defaults
M.config = {
  -- How to open RokuCode terminal
  -- Options: 'split', 'vsplit', 'tabnew', 'float'
  open_mode = 'vsplit',

  -- Terminal size
  split_height = 20, -- Height for horizontal split
  split_width = 80,  -- Width for vertical split

  -- Floating window settings (for open_mode = 'float')
  float = {
    width = 0.8,     -- 80% of editor width
    height = 0.8,    -- 80% of editor height
    border = 'rounded',
  },

  -- Command to run (adjust if rokucode is not in PATH)
  cmd = 'rokucode',

  -- Keybindings (set to false to disable individual mappings)
  keybindings = {
    -- Open RokuCode (like Cmd+Escape in VS Code)
    open = '<C-Escape>',

    -- Open in new tab
    open_tab = '<C-S-Escape>',

    -- Send current file path to RokuCode (copies to clipboard)
    send_file = '<leader>rk',
  },
}

-- Track terminal buffer for reuse
M.term_buf = nil
M.term_win = nil

-- Open RokuCode in terminal
-- @param mode string|nil Override open_mode ('split', 'vsplit', 'tabnew', 'float')
-- @param args string|nil Additional CLI arguments
function M.open(mode, args)
  mode = mode or M.config.open_mode
  args = args or ''

  -- Build command
  local cmd = M.config.cmd
  if args ~= '' then
    cmd = cmd .. ' ' .. args
  end

  -- Check if we have an existing terminal buffer that's still valid
  if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
    -- Try to find window showing this buffer
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == M.term_buf then
        vim.api.nvim_set_current_win(win)
        vim.cmd('startinsert')
        return
      end
    end
  end

  -- Open based on mode
  if mode == 'split' then
    vim.cmd('split')
    vim.cmd('resize ' .. M.config.split_height)
    vim.cmd('terminal ' .. cmd)
  elseif mode == 'vsplit' then
    vim.cmd('vsplit')
    vim.cmd('vertical resize ' .. M.config.split_width)
    vim.cmd('terminal ' .. cmd)
  elseif mode == 'tabnew' then
    vim.cmd('tabnew')
    vim.cmd('terminal ' .. cmd)
  elseif mode == 'float' then
    M.open_float(cmd)
    return
  else
    -- Default: current window
    vim.cmd('terminal ' .. cmd)
  end

  -- Track the terminal buffer
  M.term_buf = vim.api.nvim_get_current_buf()
  M.term_win = vim.api.nvim_get_current_win()

  -- Enter insert mode
  vim.cmd('startinsert')
end

-- Open RokuCode in floating window
-- @param cmd string Command to run
function M.open_float(cmd)
  local width = math.floor(vim.o.columns * M.config.float.width)
  local height = math.floor(vim.o.lines * M.config.float.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = M.config.float.border,
  })

  -- Open terminal in the floating window
  vim.fn.termopen(cmd, {
    on_exit = function()
      -- Close floating window when terminal exits
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })

  -- Track terminal
  M.term_buf = buf
  M.term_win = win

  -- Enter insert mode
  vim.cmd('startinsert')
end

-- Send current file path to clipboard
-- This allows easy reference in RokuCode chat
function M.send_current_file()
  local filepath = vim.fn.expand('%:p')

  if filepath == '' then
    vim.notify('No file open', vim.log.levels.WARN)
    return
  end

  -- Copy to clipboard
  vim.fn.setreg('+', filepath)
  vim.notify('File path copied: ' .. filepath, vim.log.levels.INFO)
end

-- Get current file path (for use in chat)
function M.get_current_file()
  return vim.fn.expand('%:p')
end

-- Get current selection (for use in chat)
function M.get_selection()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '' then
    vim.notify('No visual selection', vim.log.levels.WARN)
    return nil
  end

  -- Get selection range
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return nil
  end

  -- Trim to selection
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  return table.concat(lines, '\n')
end

-- Setup function
-- @param user_config table|nil Configuration overrides
function M.setup(user_config)
  warn_deprecated()

  -- Merge user config
  if user_config then
    M.config = vim.tbl_deep_extend('force', M.config, user_config)
  end

  -- Register commands
  vim.api.nvim_create_user_command('RokuCode', function(opts)
    M.open(nil, opts.args)
  end, { nargs = '*', desc = 'Open RokuCode AI chat' })

  vim.api.nvim_create_user_command('RokuCodeTab', function(opts)
    M.open('tabnew', opts.args)
  end, { nargs = '*', desc = 'Open RokuCode in new tab' })

  vim.api.nvim_create_user_command('RokuCodeSplit', function(opts)
    M.open('split', opts.args)
  end, { nargs = '*', desc = 'Open RokuCode in horizontal split' })

  vim.api.nvim_create_user_command('RokuCodeVsplit', function(opts)
    M.open('vsplit', opts.args)
  end, { nargs = '*', desc = 'Open RokuCode in vertical split' })

  vim.api.nvim_create_user_command('RokuCodeFloat', function(opts)
    M.open('float', opts.args)
  end, { nargs = '*', desc = 'Open RokuCode in floating window' })

  -- Register keybindings
  if M.config.keybindings.open then
    vim.keymap.set('n', M.config.keybindings.open, function()
      M.open()
    end, { desc = 'Open RokuCode' })
  end

  if M.config.keybindings.open_tab then
    vim.keymap.set('n', M.config.keybindings.open_tab, function()
      M.open('tabnew')
    end, { desc = 'Open RokuCode in new tab' })
  end

  if M.config.keybindings.send_file then
    vim.keymap.set('n', M.config.keybindings.send_file, M.send_current_file,
      { desc = 'Copy file path for RokuCode' })
  end
end

return M
