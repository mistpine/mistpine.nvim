-- lualine theme. lualine's default `auto` theme loads it when mistpine is the
-- colorscheme, so `theme = "auto"` (LazyVim's default) and `theme = "mistpine"` match.
local c = require("mistpine").colors()

--- Mode block in the mode's accent, then the raised status line surfaces.
local function mode(accent)
  return {
    a = { fg = c.bg, bg = accent, gui = "bold" },
    b = { fg = c.subtle, bg = c.selection },
    c = { fg = c.status_fg, bg = c.status_bg },
  }
end

return {
  normal = mode(c.accent),
  insert = mode(c.green),
  visual = mode(c.purple),
  replace = mode(c.red),
  command = mode(c.yellow),
  terminal = mode(c.cyan),
  inactive = {
    a = { fg = c.muted, bg = c.panel, gui = "bold" },
    b = { fg = c.muted, bg = c.panel },
    c = { fg = c.muted, bg = c.panel },
  },
}
