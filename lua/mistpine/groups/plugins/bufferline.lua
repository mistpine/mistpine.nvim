-- akinsho/bufferline.nvim
--
-- bufferline derives its colors by tinting the colorscheme's, which lands off
-- the palette, but it keeps groups a colorscheme already defines (`themable`).
-- Inactive tabs are recessed (bg0), the selected one sits on the editor (bg1).
local M = {}

---@param c mistpine.Colors
---@param opts mistpine.Config
function M.get(c, opts)
  local states = {
    [""] = { bg = c.tab_inactive, fg = c.muted },
    Visible = { bg = c.tab_inactive, fg = c.subtle },
    Selected = { bg = opts.transparent and "NONE" or c.bg, fg = c.fg, bold = true },
  }

  local groups = {
    BufferLineFill = { bg = c.tab_inactive },
    BufferLineBackground = { fg = c.muted, bg = c.tab_inactive },
    BufferLineGroupLabel = { fg = c.bg, bg = c.muted },
    BufferLineGroupSeparator = { fg = c.muted, bg = c.tab_inactive },
    BufferLineOffsetSeparator = { fg = c.border, bg = c.tab_inactive },
    BufferLineTruncMarker = { fg = c.muted, bg = c.tab_inactive },
    BufferLineIndicatorVisible = { fg = c.tab_inactive, bg = c.tab_inactive },
    BufferLineIndicatorSelected = { fg = c.accent, bg = states.Selected.bg },
    BufferLineTab = { fg = c.muted, bg = c.tab_inactive },
    BufferLineTabSelected = { fg = c.accent, bg = states.Selected.bg, bold = true },
    BufferLineTabClose = { fg = c.muted, bg = c.tab_inactive },
    BufferLineTabSeparator = { fg = c.border, bg = c.tab_inactive },
    BufferLineTabSeparatorSelected = { fg = c.border, bg = states.Selected.bg },
  }

  local severities = { Error = c.error, Warning = c.warning, Info = c.info, Hint = c.hint }
  for state, base in pairs(states) do
    local function set(element, hl)
      groups["BufferLine" .. element .. state] = vim.tbl_extend("force", { bg = base.bg }, hl)
    end
    set("Buffer", { fg = base.fg, bold = base.bold })
    set("Numbers", { fg = base.fg, bold = base.bold })
    set("CloseButton", { fg = state == "Selected" and c.fg or c.muted })
    set("Diagnostic", { fg = state == "Selected" and c.subtle or c.muted })
    set("Modified", { fg = c.orange })
    set("Duplicate", { fg = c.muted, italic = true })
    set("Separator", { fg = c.border })
    set("Pick", { fg = c.red, bold = true })
    for severity, color in pairs(severities) do
      local selected = state == "Selected"
      set(severity, { fg = selected and color or base.fg, sp = color, bold = base.bold })
      set(severity .. "Diagnostic", { fg = color, sp = color, bold = base.bold })
    end
  end
  return groups
end

return M
