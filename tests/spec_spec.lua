-- The colorscheme implements the mistpine spec (palette/mistpine.json upstream).
local h = require("helpers")
local util = require("mistpine.util")

--- Spec syntax token → groups that must carry exactly its color and style.
local SYNTAX = {
  comment = { "Comment", "@comment", "@comment.documentation" },
  keyword = { "Keyword", "Statement", "@keyword", "@keyword.function", "@keyword.import" },
  control = { "Conditional", "Repeat", "@keyword.return", "@keyword.conditional", "@keyword.repeat" },
  ["function"] = { "Function", "@function", "@function.call" },
  method = { "@function.method", "@function.method.call" },
  string = { "String", "@string" },
  escape = { "Special", "@string.escape" },
  regex = { "Regexp", "@string.regexp" },
  number = { "Number", "@number", "@number.float" },
  constant = { "Constant", "@constant", "@constant.builtin" },
  boolean = { "Boolean", "@boolean" },
  type = { "Type", "@type", "@type.builtin", "@constructor" },
  builtin = { "@function.builtin", "@variable.builtin", "@module.builtin" },
  variable = { "Identifier", "@variable" },
  parameter = { "@variable.parameter" },
  property = { "@property", "@variable.member" },
  operator = { "Operator", "@operator" },
  punctuation = { "Delimiter", "@punctuation.delimiter", "@punctuation.bracket" },
  tag = { "Tag", "@tag" },
  attribute = { "@attribute", "@tag.attribute" },
  namespace = { "@module" },
  macro = { "Macro", "PreProc", "@function.macro", "@constant.macro" },
  heading = { "@markup.heading" },
  link = { "@markup.link", "@string.special.url" },
}

--- Spec UI token → { group, attribute } pairs that must use it.
local UI = {
  editorBg = { { "Normal", "bg" } },
  editorFg = { { "Normal", "fg" }, { "NormalFloat", "fg" } },
  panelBg = { { "NormalFloat", "bg" }, { "FloatBorder", "bg" } },
  cursorLine = { { "CursorLine", "bg" }, { "ColorColumn", "bg" } },
  lineNr = { { "LineNr", "fg" } },
  lineNrActive = { { "CursorLineNr", "fg" } },
  selection = { { "Visual", "bg" } },
  nonText = { { "NonText", "fg" }, { "Whitespace", "fg" } },
  border = { { "FloatBorder", "fg" }, { "WinSeparator", "fg" } },
  matchParen = { { "MatchParen", "bg" } },
  searchBg = { { "Search", "bg" } },
  curSearchBg = { { "CurSearch", "bg" }, { "IncSearch", "bg" } },
  accent = { { "FloatTitle", "fg" }, { "Directory", "fg" } },
  statusBg = { { "StatusLine", "bg" } },
  statusFg = { { "StatusLine", "fg" } },
  pmenuBg = { { "Pmenu", "bg" } },
  pmenuSel = { { "PmenuSel", "bg" } },
  tabInactiveBg = { { "TabLine", "bg" }, { "TabLineFill", "bg" } },
  error = { { "DiagnosticError", "fg" }, { "ErrorMsg", "fg" } },
  warning = { { "DiagnosticWarn", "fg" }, { "WarningMsg", "fg" } },
  info = { { "DiagnosticInfo", "fg" } },
  hint = { { "DiagnosticHint", "fg" } },
  ok = { { "DiagnosticOk", "fg" } },
  diffAdd = { { "DiffAdd", "bg" } },
  diffChange = { { "DiffChange", "bg" } },
  diffDelete = { { "DiffDelete", "bg" } },
  diffText = { { "DiffText", "bg" } },
  gitAdd = { { "Added", "fg" }, { "GitSignsAdd", "fg" } },
  gitChange = { { "Changed", "fg" }, { "GitSignsChange", "fg" } },
  gitDelete = { { "Removed", "fg" }, { "GitSignsDelete", "fg" } },
}

return {
  {
    "every spec syntax token reaches its groups, with its style",
    function()
      h.load()
      local spec = require("mistpine.palette")
      for token, groups in pairs(SYNTAX) do
        local e = spec.syntax[token]
        h.ok(e, "spec has no syntax." .. token)
        for _, group in ipairs(groups) do
          local hl = h.hl(group)
          h.eq(hl.fg, e[1], group .. " (" .. token .. ")")
          for _, style in ipairs({ "bold", "italic" }) do
            h.eq(hl[style], e[style], group .. " " .. style)
          end
        end
      end
      for token in pairs(spec.syntax) do
        h.ok(SYNTAX[token], "syntax." .. token .. " is not tested")
      end
    end,
  },
  {
    "every spec UI token reaches its groups",
    function()
      h.load()
      local spec = require("mistpine.palette")
      for token, uses in pairs(UI) do
        for _, use in ipairs(uses) do
          h.eq(h.hl(use[1])[use[2]], spec.ui[token][1], use[1] .. "." .. use[2] .. " (" .. token .. ")")
        end
      end
      for token in pairs(spec.ui) do
        h.ok(UI[token], "ui." .. token .. " is not tested")
      end
    end,
  },
  {
    "blends are recomputed exactly as the spec computes them",
    function()
      local spec = require("mistpine.palette")
      for token, e in pairs(spec.ui) do
        if e.mix then
          local got = util.mix(spec.palette.bg1, spec.palette[e.mix[2]], e.mix[3])
          h.eq(got, e[1], "ui." .. token)
        end
      end
    end,
  },
  {
    "syntax and diagnostic colors clear 4.5:1 on the editor background",
    function()
      h.load()
      local bg = h.hl("Normal").bg
      local groups = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint", "DiagnosticOk" }
      for _, list in pairs(SYNTAX) do
        vim.list_extend(groups, list)
      end
      for _, name in ipairs(vim.tbl_keys(vim.api.nvim_get_hl(0, {}))) do
        if name:match("^@[%w.]+$") and not name:match("^@lsp") then
          table.insert(groups, name)
        end
      end
      for _, group in ipairs(groups) do
        local hl = h.hl(group)
        if hl.fg and not hl.bg then
          local ratio = util.contrast(hl.fg, bg)
          h.ok(ratio >= 4.5, string.format("%s %s is %.2f:1 on %s", group, hl.fg, ratio, bg))
        end
      end
    end,
  },
  {
    "text on its own background clears 4.5:1",
    function()
      h.load()
      local c = require("mistpine").colors()
      local groups = {
        "NormalFloat",
        "Pmenu",
        "PmenuExtra",
        "PmenuMatch",
        "PmenuMatchSel",
        "StatusLine",
        "StatusLineNC",
        "TabLine",
        "TabLineSel",
        "Folded",
        "FloatTitle",
        "FloatFooter",
        "Search",
        "CurSearch",
        "Substitute",
        "LspInlayHint",
        "DiagnosticVirtualTextError",
        "DiagnosticVirtualTextWarn",
        "DiagnosticVirtualTextInfo",
        "DiagnosticVirtualTextHint",
        "DiagnosticVirtualTextOk",
        "@comment.error",
        "@comment.warning",
        "@comment.todo",
        "@comment.note",
        "Todo",
        "QuickFixLine",
        "BufferLineBackground",
        "BufferLineBufferSelected",
        "TelescopeSelection",
        "LazyH1",
        "MasonHeader",
        "InclineNormal",
        "NoiceMini",
      }
      for _, group in ipairs(groups) do
        local hl = h.hl(group)
        local fg, bg = hl.fg or c.fg, hl.bg or c.bg
        local ratio = util.contrast(fg, bg)
        h.ok(ratio >= 4.5, string.format("%s %s on %s is %.2f:1", group, fg, bg, ratio))
      end
    end,
  },
}
