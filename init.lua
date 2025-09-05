vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
-- bootstrap lazy and all plugins.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local is_mac = vim.uv.os_uname().sysname == "Darwin"
-- local is_linux = vim.uv.os_uname().sysname == "Linux"

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        if is_mac then
            return
        end
        vim.highlight.on_yank()
        local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
        copy_to_unnamedplus(vim.v.event.regcontents)
        local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
        copy_to_unnamed(vim.v.event.regcontents)
    end
})

-- Disable OSC52 by default, enable it only when needed
local termfeatures = vim.g.termfeatures or {}
print(vim.inspect(termfeatures))
termfeatures.osc52 = false
vim.g.termfeatures = termfeatures

-- vim.g.clipboard = {
--   name = 'xsel',
--   copy = {
--     ['+'] = 'xsel --nodetach -i -b',
--     ['*'] = 'xsel --nodetach -i -b',
--   },
--   paste = {
--     ['+'] = 'xsel -o -b',
--     ['*'] = 'xsel -o -b',
--   },
--   cache_enabled = 1,
-- }

 -- if running inside ssh and kitty terminal, set clipboard.
-- if vim.env.SSH_CONNECTION and vim.env.TERM == "xterm-kitty" then
--   vim.g.clipboard = {
--     name = 'OSC 52',
--     copy = {
--       ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
--       ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
--     },
--     paste = {
--       ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
--       ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
--     },
--   }
-- end

local autocmd = vim.api.nvim_create_autocmd

vim.api.nvim_create_autocmd("FileType", {
  pattern = "codecompanion",
  callback = function()
    vim.b.cmp_enabled = false  -- blink respects this buffer variable
    vim.b.copilot_enabled = false -- copilot respects this buffer variable
  end,
})

-- allows quit all buffers without saving
vim.api.nvim_create_user_command("Q", "qa<bang>", {
  bang = true,
})
autocmd("VimEnter", {
  -- pattern = "",
  callback = function(data)
    -- buffer is a directory
    local directory = vim.fn.isdirectory(data.file) == 1

    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

    if not directory and not no_name then
      return
    end

    if directory then
      -- change to the directory
      vim.cmd.cd(data.file)
    end

    -- require("nvim-tree.api").tree.toggle { focus = false }

    if no_name then
      vim.cmd "Nvdash"
    end
  end,
  desc = "Open NvimTree on startup",
})

vim.api.nvim_create_user_command("TabMode", function()
  if vim.opt.expandtab._value == true then
    vim.opt.expandtab = false
    vim.opt.list = true
  else
    vim.opt.expandtab = true
    vim.opt.list = false
  end
end, { desc = "Toggle Tab mode" })

vim.api.nvim_create_user_command("Indent4", function()
  vim.bo.shiftwidth = 4
  vim.bo.tabstop = 4
  vim.bo.expandtab = true
end, { desc = "Set indent width to 4 spaces" })

vim.api.nvim_create_user_command("Indent2", function()
  vim.bo.shiftwidth = 2
  vim.bo.tabstop = 2
  vim.bo.expandtab = true
end, { desc = "Set indent width to 2 spaces" })


local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },
  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

function Printt(t)
  print(vim.inspect(t))
end
-- Restore the cursor to the last known position when reopening a file
-- vim.api.nvim_create_autocmd("BufReadPost", {
--     pattern = "*",
--     callback = function()
--         local last_position = vim.fn.line("'\"")
--         if last_position > 1 and last_position <= vim.fn.line("$") then
--             vim.api.nvim_win_set_cursor(0, {last_position, 0})
--         end
--     end,
-- })
