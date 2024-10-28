vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
-- bootstrap lazy and all plugins.
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

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
