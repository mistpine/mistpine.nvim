-- folke/zen-mode.nvim: it would shade Normal; keep the backdrop on the palette.
local M = {}

---@param c mistpine.Colors
function M.get(c)
  return {
    ZenBg = { fg = c.bg0, bg = c.bg0 },
  }
end

return M
