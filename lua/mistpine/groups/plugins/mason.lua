-- mason-org/mason.nvim: its defaults are hard-coded hex colors.
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    MasonNormal = "NormalFloat",
    MasonHeader = { fg = c.bg, bg = c.yellow, bold = true },
    MasonHeaderSecondary = { fg = c.bg, bg = c.accent, bold = true },
    MasonHighlight = { fg = c.accent },
    MasonHighlightBlock = { fg = c.bg, bg = c.accent },
    MasonHighlightBlockBold = { fg = c.bg, bg = c.accent, bold = true },
    MasonHighlightSecondary = { fg = c.yellow },
    MasonHighlightBlockSecondary = { fg = c.bg, bg = c.yellow },
    MasonHighlightBlockBoldSecondary = { fg = c.bg, bg = c.yellow, bold = true },
    MasonLink = { fg = c.syntax.link.fg, underline = true },
    MasonMuted = { fg = c.muted },
    MasonMutedBlock = { fg = c.fg, bg = c.selection },
    MasonMutedBlockBold = { fg = c.fg, bg = c.selection, bold = true },
    MasonError = { fg = c.error },
    MasonWarning = { fg = c.warning },
    MasonHeading = { fg = c.fg, bold = true },
  }
end

return M
