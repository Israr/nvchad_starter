require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local lazy = {}

-- Function to open LazyGit in a floating terminal
function _G.snack_term()
  Snacks.terminal()
end

function _G.toggle_lazygit()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.o.columns
  local height = vim.o.lines
  local win_width = math.ceil(width * 1.0)
  local win_height = math.ceil(height * 1.0)
  local row = math.ceil((height - win_height) / 2)
  local col = math.ceil((width - win_width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded'
  })

  vim.fn.termopen("lazygit")
  vim.cmd("startinsert")
end

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map({ "n", "t" }, "<C-\\>", function()
  require("nvchad.term").toggle { pos = "float", id = "floatTerm2", float_opts = {width=0.8, height=0.8, row=0.1, col=0.1}}
end, { desc = "floating terminal" })

-- map('n', '<leader>gg', '<cmd>lua toggle_lazygit()<CR>', {desc = "Toggle lazygit"})
map('n', '<leader>gg', '<cmd>lua Snacks.lazygit()<CR>', {desc = "Toggle lazygit"})
map('n', '<leader>e',  '<cmd>lua Snacks.explorer()<CR>', {desc = "Toggle nvim tree"})
map('n', '<leader>t',  '<cmd>TabMode<CR>', {desc = "Toggle tab mode"})
map('n', '<leader>w',  '<cmd>update<CR>', {desc = "Save/Update"})
map('n', '<leader>r',  '<cmd>e ~/roku/roku.sh<CR>', {desc = "Open roku.sh"})
map('n', '<leader>c',  '<cmd>bd<CR>', {desc = "Close buffer"})
map('n', '<leader>C',  '<cmd>CodeCompanionActions<CR>', {desc = "Close buffer"})
map('n', '<leader>;',  '<cmd>Nvdash<CR>', {desc = "Open nvDash"})
map('n', '<leader>gh', '<cmd>NvCheatsheet<CR>', {desc = "Open cheatsheet"})
map('n', '<leader>gm', '<cmd>Telescope git_commits<CR>', {desc = "Telescope git_commits"})
map('n', '<leader>ww', '<cmd>w<CR>', {desc = "savetab mode"})
map('n', '<leader>cd', '<cmd>cd %:h<CR>', {desc = "CD to file dir"})

lazy.copilot = function()
  map("i", "<C-l>", function()
    vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
  end, { desc = "copilot Accept", replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true })
  -- map("i", "<C-Space>", function()
  --   vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
  -- end, { desc = "copilot Accept", replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true })
end

lazy.hop = function()
  map("n", "<leader>j", "<cmd>HopWord<cr>", { desc = "Hop Word" })
  map("n", "<leader>k", "<cmd>HopChar1<cr>", { desc = "Hop Char" })
end
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

return lazy
