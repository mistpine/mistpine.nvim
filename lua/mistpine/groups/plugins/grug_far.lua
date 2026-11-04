-- MagicDuck/grug-far.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    GrugFarInputLabel = { fg = c.accent, bold = true },
    GrugFarInputPlaceholder = { fg = c.muted, italic = true },
    GrugFarHelpHeader = { fg = c.muted },
    GrugFarHelpHeaderKey = { fg = c.orange },
    GrugFarHelpWinActionKey = { fg = c.orange },
    GrugFarHelpWinActionPrefix = { fg = c.accent },
    GrugFarHelpWinActionText = { fg = c.fg },
    GrugFarHelpWinHeader = { fg = c.accent, bold = true },
    GrugFarResultsHeader = { fg = c.muted },
    GrugFarResultsStats = { fg = c.muted },
    GrugFarResultsPath = { fg = c.accent, underline = true },
    GrugFarResultsLineNr = { fg = c.line_nr },
    GrugFarResultsCursorLineNo = { fg = c.line_nr_active, bold = true },
    GrugFarResultsMatch = { fg = c.bg, bg = c.orange },
    GrugFarCurrentMatch = { fg = c.bg, bg = c.orange, bold = true },
    GrugFarResultsMatchAdded = { fg = c.git_add, bg = c.diff_add },
    GrugFarResultsMatchRemoved = { fg = c.git_delete, bg = c.diff_delete, strikethrough = true },
    GrugFarResultsActionMessage = { fg = c.accent },
    GrugFarResultsNumberLabel = { fg = c.purple },
  }
end

return M
