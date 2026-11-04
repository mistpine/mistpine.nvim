-- nvim-telescope/telescope.nvim (and telescope-file-browser.nvim)
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    TelescopeNormal = "NormalFloat",
    TelescopeBorder = "FloatBorder",
    TelescopeTitle = "FloatTitle",
    TelescopePromptNormal = "NormalFloat",
    TelescopePromptBorder = "FloatBorder",
    TelescopePromptTitle = "FloatTitle",
    TelescopePromptPrefix = { fg = c.accent },
    TelescopePromptCounter = { fg = c.muted },
    TelescopeResultsNormal = "NormalFloat",
    TelescopeResultsBorder = "FloatBorder",
    TelescopeResultsTitle = "FloatTitle",
    TelescopePreviewNormal = "NormalFloat",
    TelescopePreviewBorder = "FloatBorder",
    TelescopePreviewTitle = "FloatTitle",
    TelescopeSelection = { fg = c.fg, bg = c.selection, bold = true },
    TelescopeSelectionCaret = { fg = c.orange, bg = c.selection },
    TelescopeMultiSelection = { fg = c.yellow },
    TelescopeMultiIcon = { fg = c.yellow },
    TelescopeMatching = { fg = c.orange, bold = true },
    TelescopePreviewLine = "Visual",
    TelescopePreviewMatch = "Search",
    TelescopePreviewHyphen = { fg = c.muted },
    TelescopeResultsDiffUntracked = { fg = c.muted },
    TelescopeResultsSpecialComment = { fg = c.muted },
  }
end

return M
