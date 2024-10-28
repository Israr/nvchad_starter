require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local lazy = {}

-- Function to open LazyGit in a floating terminal
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

map('n', '<leader>lg', ':lua toggle_lazygit()<CR>', {desc = "Toggle lazygit"})
map('n', '<leader>e', ':NvimTreeToggle<CR>', {desc = "Toggle nvim tree"})

lazy.copilot = function()
  map("i", "<C-Space>", function()
    vim.fn.feedkeys(vim.fn["copilot#Accept"](), "")
  end, { desc = "copilot Accept", replace_keycodes = true, nowait = true, silent = true, expr = true, noremap = true })
end

lazy.hop = function()
  map("n", "<leader>j", "<cmd>HopWord<cr>", { desc = "Hop Word" })
  map("n", "<leader>k", "<cmd>HopChar1<cr>", { desc = "Hop Char" })
end
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

return lazy
