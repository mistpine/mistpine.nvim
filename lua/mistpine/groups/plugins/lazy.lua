-- folke/lazy.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    LazyNormal = "NormalFloat",
    LazyH1 = { fg = c.bg, bg = c.accent, bold = true },
    LazyH2 = { fg = c.fg, bold = true },
    LazyButton = { fg = c.subtle, bg = c.cursor_line },
    LazyButtonActive = { fg = c.fg, bg = c.selection, bold = true },
    LazyComment = { fg = c.muted },
    LazyDimmed = { fg = c.muted },
    LazyProp = { fg = c.muted },
    LazyValue = { fg = c.syntax.string.fg },
    LazySpecial = { fg = c.accent },
    LazyProgressDone = { fg = c.accent },
    LazyProgressTodo = { fg = c.border },
    LazyCommit = { fg = c.orange },
    LazyCommitType = { fg = c.yellow, bold = true },
    LazyCommitScope = { fg = c.muted, italic = true },
    LazyCommitIssue = { fg = c.purple },
    LazyDir = { fg = c.syntax.link.fg },
    LazyUrl = { fg = c.syntax.link.fg, underline = true },
    LazyReasonPlugin = { fg = c.accent },
    LazyReasonEvent = { fg = c.yellow },
    LazyReasonKeys = { fg = c.red },
    LazyReasonStart = { fg = c.cyan },
    LazyReasonSource = { fg = c.green },
    LazyReasonFt = { fg = c.purple },
    LazyReasonCmd = { fg = c.orange },
    LazyReasonImport = { fg = c.fg },
    LazyReasonRequire = { fg = c.blue },
    LazyReasonRuntime = { fg = c.cyan },
    LazyNoCond = { fg = c.warning },
    LazyLocal = { fg = c.purple },
  }
end

return M
