-- Editor interface: `:h highlight-groups`.
local M = {}

---@param c mistpine.Colors
---@param opts mistpine.Config
function M.get(c, opts)
  local bg = opts.transparent and "NONE" or c.bg
  local s = c.syntax

  return {
    -- Surfaces: bg1 is the canvas, raised ones use bg2, recessed ones bg0.
    Normal = { fg = c.fg, bg = bg },
    NormalNC = opts.dim_inactive and { fg = c.fg, bg = c.panel } or { fg = c.fg, bg = bg },
    NormalFloat = { fg = c.fg, bg = c.panel },
    FloatBorder = { fg = c.border, bg = c.panel },
    FloatTitle = { fg = c.accent, bg = c.panel, bold = true },
    FloatFooter = { fg = c.muted, bg = c.panel },
    FloatShadow = { bg = c.bg0, blend = 80 },
    FloatShadowThrough = { bg = c.bg0, blend = 100 },
    MsgArea = { fg = c.fg },
    MsgSeparator = { fg = c.border, bg = c.panel },
    Ignore = { fg = c.dim },

    -- Cursor and lines
    Cursor = { fg = c.bg, bg = c.fg },
    lCursor = "Cursor",
    CursorIM = "Cursor",
    TermCursor = { fg = c.bg, bg = c.fg },
    TermCursorNC = { fg = c.bg, bg = c.muted }, -- Neovim 0.10
    CursorLine = { bg = c.cursor_line },
    CursorColumn = { bg = c.cursor_line },
    ColorColumn = { bg = c.cursor_line },
    LineNr = { fg = c.line_nr },
    LineNrAbove = "LineNr",
    LineNrBelow = "LineNr",
    CursorLineNr = { fg = c.line_nr_active, bold = true },
    SignColumn = { fg = c.line_nr, bg = bg },
    CursorLineSign = "SignColumn",
    FoldColumn = { fg = c.line_nr, bg = bg },
    CursorLineFold = "FoldColumn",
    Folded = { fg = c.muted, bg = c.cursor_line },
    QuickFixLine = { bg = c.selection, bold = true },

    -- Selection and search
    Visual = { bg = c.selection },
    VisualNOS = "Visual",
    Search = { fg = c.fg, bg = c.search },
    CurSearch = { fg = c.bg, bg = c.cur_search, bold = true },
    IncSearch = "CurSearch",
    Substitute = { fg = c.bg, bg = c.red },
    MatchParen = { fg = c.orange, bg = c.match_paren, bold = true },

    -- Invisible characters
    NonText = { fg = c.nontext },
    Whitespace = { fg = c.nontext },
    SpecialKey = { fg = c.nontext },
    EndOfBuffer = { fg = c.nontext },
    Conceal = { fg = c.muted },

    -- Menus and completion (`:h ins-completion-menu`)
    Pmenu = { fg = c.fg, bg = c.pmenu },
    PmenuSel = { bg = c.pmenu_sel, bold = true },
    PmenuKind = { fg = c.yellow, bg = c.pmenu },
    PmenuKindSel = { fg = c.yellow, bg = c.pmenu_sel, bold = true },
    PmenuExtra = { fg = c.muted, bg = c.pmenu },
    PmenuExtraSel = { fg = c.muted, bg = c.pmenu_sel, bold = true },
    PmenuMatch = { fg = c.orange, bg = c.pmenu, bold = true },
    PmenuMatchSel = { fg = c.orange, bg = c.pmenu_sel, bold = true },
    PmenuSbar = { bg = c.pmenu },
    PmenuThumb = { bg = c.border },
    PmenuBorder = { fg = c.border, bg = c.pmenu },
    PmenuShadow = "FloatShadow",
    PmenuShadowThrough = "FloatShadowThrough",
    ComplMatchIns = { fg = c.muted },
    ComplHint = { fg = c.muted },
    ComplHintMore = { fg = c.accent },
    PreInsert = { fg = c.muted },
    WildMenu = "PmenuSel",
    Menu = "Pmenu",
    Tooltip = "NormalFloat",
    Scrollbar = "PmenuSbar",
    SnippetTabstop = { bg = c.selection },
    SnippetTabstopActive = { bg = c.selection, underline = true },

    -- Status line, tab line, window bar and separators
    StatusLine = { fg = c.status_fg, bg = c.status_bg },
    StatusLineNC = { fg = c.muted, bg = c.panel },
    StatusLineTerm = "StatusLine",
    StatusLineTermNC = "StatusLineNC",
    TabLine = { fg = c.muted, bg = c.tab_inactive },
    TabLineFill = { bg = c.tab_inactive },
    TabLineSel = { fg = c.fg, bg = c.bg, bold = true },
    WinBar = { fg = c.subtle, bold = true },
    WinBarNC = { fg = c.muted },
    WinSeparator = { fg = c.border, bg = bg },
    VertSplit = "WinSeparator",

    -- Messages
    Title = { fg = s.heading.fg, bold = true },
    Directory = { fg = c.accent },
    ErrorMsg = { fg = c.error },
    WarningMsg = { fg = c.warning },
    MoreMsg = { fg = c.ok },
    ModeMsg = { fg = c.subtle, bold = true },
    OkMsg = { fg = c.ok },
    Question = { fg = c.accent },
    StderrMsg = "ErrorMsg",
    StdoutMsg = "MsgArea",
    NvimInternalError = { fg = c.bg, bg = c.error },

    -- Spelling
    SpellBad = { sp = c.error, undercurl = true },
    SpellCap = { sp = c.warning, undercurl = true },
    SpellLocal = { sp = c.info, undercurl = true },
    SpellRare = { sp = c.hint, undercurl = true },

    -- Diff mode and diff text
    DiffAdd = { bg = c.diff_add },
    DiffChange = { bg = c.diff_change },
    DiffDelete = { fg = c.git_delete, bg = c.diff_delete },
    DiffText = { bg = c.diff_text },
    DiffTextAdd = { bg = c.diff_text_add },
    Added = { fg = c.git_add },
    Changed = { fg = c.git_change },
    Removed = { fg = c.git_delete },
    diffAdded = "Added",
    diffChanged = "Changed",
    diffRemoved = "Removed",
    diffFile = { fg = c.accent, bold = true },
    diffNewFile = { fg = c.git_add, bold = true },
    diffOldFile = { fg = c.git_delete, bold = true },
    diffIndexLine = { fg = c.muted },
    diffLine = { fg = c.cyan },
    diffSubname = { fg = c.subtle },

    -- :checkhealth, :terminal debugging, redraw debugging
    healthError = { fg = c.error },
    healthSuccess = { fg = c.ok },
    healthWarning = { fg = c.warning },
    debugPC = { bg = c.debug_line },
    debugBreakpoint = { fg = c.error, bg = c.virtual_error },
    RedrawDebugNormal = { reverse = true },
    RedrawDebugClear = { bg = c.search },
    RedrawDebugComposed = { bg = c.diff_add },
    RedrawDebugRecompose = { bg = c.diff_delete },

    -- Plain emphasis (Neovim 0.13 defines these; plugins such as LazyVim's status
    -- line and pickers use them earlier). Styles only, so they combine with any color.
    Bold = { bold = true },
    Italic = { italic = true },
    BoldItalic = { bold = true, italic = true },
    Dimmed = { fg = c.muted },

    -- Multiple cursors (Neovim 0.13)
    MCursor = { fg = c.bg, bg = c.cur_search },
    MCursorVisual = "Visual",
  }
end

return M
