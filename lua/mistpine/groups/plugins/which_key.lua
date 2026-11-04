-- folke/which-key.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    WhichKey = { fg = c.orange },
    WhichKeyGroup = { fg = c.accent },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.muted },
    WhichKeyValue = { fg = c.muted },
    WhichKeyNormal = "NormalFloat",
    WhichKeyBorder = "FloatBorder",
    WhichKeyTitle = "FloatTitle",
    WhichKeyIcon = { fg = c.accent },
  }
end

return M
