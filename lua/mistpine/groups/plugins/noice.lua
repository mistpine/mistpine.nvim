-- folke/noice.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    NoiceCmdline = "MsgArea",
    NoiceCmdlinePopup = "NormalFloat",
    NoiceCmdlinePopupBorder = { fg = c.accent, bg = c.panel },
    NoiceCmdlinePopupTitle = { fg = c.accent, bg = c.panel, bold = true },
    NoiceCmdlineIcon = { fg = c.accent },
    NoiceCmdlinePopupBorderSearch = { fg = c.yellow, bg = c.panel },
    NoiceCmdlineIconSearch = { fg = c.yellow },
    NoiceCmdlinePrompt = { fg = c.accent, bold = true },
    NoiceConfirm = "NormalFloat",
    NoiceConfirmBorder = { fg = c.accent, bg = c.panel },
    NoicePopup = "NormalFloat",
    NoicePopupBorder = "FloatBorder",
    NoicePopupmenu = "Pmenu",
    NoicePopupmenuBorder = { fg = c.border, bg = c.pmenu },
    NoicePopupmenuMatch = { fg = c.orange, bold = true },
    NoicePopupmenuSelected = "PmenuSel",
    NoiceSplit = "NormalFloat",
    NoiceSplitBorder = "FloatBorder",
    NoiceMini = { fg = c.subtle, bg = c.bg0 },
    NoiceLspProgressTitle = { fg = c.muted },
    NoiceLspProgressClient = { fg = c.accent, bold = true },
    NoiceLspProgressSpinner = { fg = c.cyan },
    NoiceFormatProgressDone = { fg = c.bg, bg = c.accent },
    NoiceFormatProgressTodo = { fg = c.muted, bg = c.cursor_line },
    NoiceFormatEvent = { fg = c.muted },
    NoiceFormatKind = { fg = c.muted },
    NoiceFormatDate = { fg = c.muted },
    NoiceFormatTitle = { fg = c.accent, bold = true },
    NoiceFormatConfirm = "CursorLine",
    NoiceFormatConfirmDefault = "Visual",
    NoiceFormatLevelDebug = { fg = c.muted },
    NoiceFormatLevelTrace = { fg = c.dim },
    NoiceFormatLevelOff = { fg = c.dim },
    NoiceFormatLevelInfo = "DiagnosticVirtualTextInfo",
    NoiceFormatLevelWarn = "DiagnosticVirtualTextWarn",
    NoiceFormatLevelError = "DiagnosticVirtualTextError",
    NoiceVirtualText = "DiagnosticVirtualTextInfo",
    NoiceCompletionItemKindDefault = { fg = c.yellow },
  }
end

return M
