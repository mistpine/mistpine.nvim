-- folke/trouble.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    TroubleNormal = "NormalFloat",
    TroubleNormalNC = "NormalFloat",
    TroubleText = { fg = c.fg },
    TroublePreview = "Visual",
    TroubleCount = { fg = c.purple, bg = c.selection },
    TroubleCode = { fg = c.muted },
    TroubleSource = { fg = c.muted },
    TroublePos = { fg = c.muted },
    TroubleFilename = { fg = c.accent },
    TroubleBasename = { fg = c.accent },
    TroubleDirectory = { fg = c.accent },
    TroubleIconDirectory = { fg = c.accent },
    TroubleIndent = { fg = c.border },
    TroubleIndentFoldClosed = { fg = c.yellow },
    TroubleIndentFoldOpen = { fg = c.border },
  }
end

return M
