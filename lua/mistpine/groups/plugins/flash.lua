-- folke/flash.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    FlashBackdrop = { fg = c.dim },
    FlashMatch = { fg = c.fg, bg = c.search },
    FlashCurrent = { fg = c.bg, bg = c.cur_search, bold = true },
    FlashLabel = { fg = c.bg, bg = c.pink, bold = true },
    FlashPrompt = "MsgArea",
    FlashPromptIcon = { fg = c.pink },
    FlashCursor = "Cursor",
  }
end

return M
