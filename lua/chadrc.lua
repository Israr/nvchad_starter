-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "tokyonight",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

M.nvdash = {
  load_on_startup = false,
  buttons = {
       { txt = "  Find File", keys = "ff", cmd = "Telescope find_files", no_gap = true },
       { txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles", no_gap = true },
       { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep", no_gap = true},
       { txt = "󱥚  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()", no_gap = true },
       { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" , no_gap = true},
       { txt = "  Config", keys = "c", cmd = ":e ~/.config/nvim/init.lua", no_gap = true },
       { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
       {
          txt = function()
            local stats = require("lazy").stats()
            local ms = math.floor(stats.startuptime) .. " ms"
            return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
          end,
          hl = "NvDashFooter",
          no_gap = true,
       },
      { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  }
}
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
