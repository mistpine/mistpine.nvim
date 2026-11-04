-- b0o/incline.nvim: the floating file name, raised over the editor.
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    InclineNormal = { fg = c.fg, bg = c.cursor_line, bold = true },
    InclineNormalNC = { fg = c.muted, bg = c.panel },
  }
end

return M
