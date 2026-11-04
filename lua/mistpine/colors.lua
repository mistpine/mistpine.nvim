local util = require("mistpine.util")

local M = {}

---@class mistpine.Palette
---@field bg0 string Panels, floats, inactive tabs
---@field bg1 string Editor background
---@field bg2 string Cursor line, status line, menus
---@field bg3 string Selections
---@field bg4 string Borders, line numbers
---@field fg0 string Decoration only: too dim for text
---@field fg1 string Comments, muted text
---@field fg2 string Punctuation, status line text
---@field fg3 string Text
---@field red string
---@field orange string
---@field yellow string
---@field green string
---@field cyan string
---@field blue string
---@field purple string
---@field pink string
---@field brightRed string
---@field brightGreen string
---@field brightYellow string
---@field brightBlue string
---@field brightPurple string
---@field brightCyan string

---@class mistpine.Style
---@field fg string
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean

---@class mistpine.Colors: mistpine.Palette
---@field palette mistpine.Palette
---@field terminal table<string, string>
---@field ansi string[] ANSI colors 0–15 (`ansi[1]` is color 0)
---@field syntax table<string, mistpine.Style>
---@field ui table<string, string>
---@field [string] string Roles such as `bg`, `fg`, `border`, `error` and derived blends

--- Resolves the spec against a palette: every color that names a palette key or
--- blends one is recomputed, so overriding `bg1` moves everything built on it.
---@param palette mistpine.Palette
---@return mistpine.Colors
function M.resolve(palette)
  local spec = require("mistpine.palette")
  local resolved = { terminal = {}, ansi = {}, syntax = {}, ui = {} }

  local function lookup(path)
    local section, key = path:match("^(%w+)%.(%w+)$")
    return assert(resolved[section] and resolved[section][key], "unknown color " .. path)
  end

  ---@param e { [1]: string, ref?: string, mix?: { [1]: string, [2]: string, [3]: number } }
  local function color(e)
    if e.ref then
      return assert(palette[e.ref], "palette has no " .. e.ref)
    elseif e.mix then
      return util.mix(lookup(e.mix[1]), palette[e.mix[2]], e.mix[3])
    end
    return e[1]
  end

  for k, e in pairs(spec.terminal) do
    resolved.terminal[k] = color(e)
  end
  for i, e in ipairs(spec.ansi) do
    resolved.ansi[i] = color(e)
  end
  for k, e in pairs(spec.ui) do
    resolved.ui[k] = color(e)
  end
  for k, e in pairs(spec.syntax) do
    resolved.syntax[k] = { fg = color(e), bold = e.bold, italic = e.italic, underline = e.underline }
  end

  local ui = resolved.ui
  local c = vim.tbl_extend("force", {}, palette, resolved) --[[@as mistpine.Colors]]
  c.palette = palette

  -- Roles from the spec's editor UI table.
  c.bg = ui.editorBg
  c.fg = ui.editorFg
  c.panel = ui.panelBg
  c.cursor_line = ui.cursorLine
  c.line_nr = ui.lineNr
  c.line_nr_active = ui.lineNrActive
  c.selection = ui.selection
  c.nontext = ui.nonText
  c.border = ui.border
  c.match_paren = ui.matchParen
  c.search = ui.searchBg
  c.cur_search = ui.curSearchBg
  c.accent = ui.accent
  c.status_bg = ui.statusBg
  c.status_fg = ui.statusFg
  c.pmenu = ui.pmenuBg
  c.pmenu_sel = ui.pmenuSel
  c.tab_inactive = ui.tabInactiveBg
  c.error = ui.error
  c.warning = ui.warning
  c.info = ui.info
  c.hint = ui.hint
  c.ok = ui.ok
  c.diff_add = ui.diffAdd
  c.diff_change = ui.diffChange
  c.diff_delete = ui.diffDelete
  c.diff_text = ui.diffText
  c.git_add = ui.gitAdd
  c.git_change = ui.gitChange
  c.git_delete = ui.gitDelete

  -- Text tones: fg0 is decoration only, fg1 the dimmest readable text.
  c.text = palette.fg3
  c.subtle = palette.fg2
  c.muted = palette.fg1
  c.dim = palette.fg0

  -- Blends of an accent over the editor background, as the spec's diff colors are.
  local function over(hex, amount)
    return util.mix(c.bg, hex, amount)
  end
  c.diff_text_add = over(palette.green, 0.35)
  -- Diagnostic virtual text sits on a faint, recessed tint of its color: 8% over
  -- bg0 keeps every severity at 4.5:1 or more (over bg1, red would drop below).
  for _, name in ipairs({ "error", "warning", "info", "hint", "ok" }) do
    c["virtual_" .. name] = util.mix(palette.bg0, c[name], 0.08)
  end
  c.git_add_staged = over(c.git_add, 0.5)
  c.git_change_staged = over(c.git_change, 0.5)
  c.git_delete_staged = over(c.git_delete, 0.5)
  c.inline_add = over(c.git_add, 0.35)
  c.inline_change = c.diff_text
  c.inline_delete = over(c.git_delete, 0.35)
  c.debug_line = over(palette.yellow, 0.15)
  for _, name in ipairs({ "green", "blue", "yellow", "cyan", "purple", "pink" }) do
    c["heading_" .. name] = over(palette[name], 0.12)
  end

  return c
end

--- The resolved colors for the given options (default: the ones from `setup()`).
---@param opts? mistpine.Config
---@return mistpine.Colors
function M.get(opts)
  opts = opts or require("mistpine.config").options
  local palette = vim.deepcopy(require("mistpine.palette").palette)
  if opts.on_colors then
    opts.on_colors(palette)
  end
  return M.resolve(palette)
end

return M
