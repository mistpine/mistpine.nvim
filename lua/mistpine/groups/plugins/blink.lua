-- saghen/blink.cmp
local M = {}

--- Completion kinds, colored like the syntax they complete.
---@param c mistpine.Colors
function M.kinds(c)
  local s = c.syntax
  return {
    Text = c.subtle,
    Method = s.method.fg,
    Function = s["function"].fg,
    Constructor = s.type.fg,
    Field = s.property.fg,
    Variable = s.variable.fg,
    Class = s.type.fg,
    Interface = s.type.fg,
    Module = s.namespace.fg,
    Property = s.property.fg,
    Unit = s.number.fg,
    Value = s.constant.fg,
    Enum = s.type.fg,
    Keyword = s.keyword.fg,
    Snippet = c.pink,
    Color = c.orange,
    File = c.accent,
    Reference = c.cyan,
    Folder = c.accent,
    EnumMember = s.constant.fg,
    Constant = s.constant.fg,
    Struct = s.type.fg,
    Event = s.type.fg,
    Operator = s.operator.fg,
    TypeParameter = s.type.fg,
  }
end

---@param c mistpine.Colors
function M.get(c)
  local groups = {
    BlinkCmpMenu = "Pmenu",
    BlinkCmpMenuBorder = { fg = c.border, bg = c.pmenu },
    BlinkCmpMenuSelection = "PmenuSel",
    BlinkCmpScrollBarThumb = "PmenuThumb",
    BlinkCmpScrollBarGutter = "PmenuSbar",
    BlinkCmpLabel = { fg = c.fg },
    BlinkCmpLabelMatch = { fg = c.orange, bold = true },
    BlinkCmpLabelDeprecated = { fg = c.muted, strikethrough = true },
    BlinkCmpLabelDetail = { fg = c.muted },
    BlinkCmpLabelDescription = { fg = c.muted },
    BlinkCmpSource = { fg = c.muted },
    BlinkCmpGhostText = { fg = c.muted },
    BlinkCmpKind = { fg = c.yellow },
    BlinkCmpDoc = "NormalFloat",
    BlinkCmpDocBorder = "FloatBorder",
    BlinkCmpDocSeparator = { fg = c.border, bg = c.panel },
    BlinkCmpDocCursorLine = "Visual",
    BlinkCmpSignatureHelp = "NormalFloat",
    BlinkCmpSignatureHelpBorder = "FloatBorder",
    BlinkCmpSignatureHelpActiveParameter = "LspSignatureActiveParameter",
  }
  for kind, fg in pairs(M.kinds(c)) do
    groups["BlinkCmpKind" .. kind] = { fg = fg }
  end
  return groups
end

return M
