-- LSP: semantic tokens (`:h lsp-semantic-highlight`), references, inlay hints
-- and diagnostics (`:h diagnostic-highlights`).
local M = {}

---@param c mistpine.Colors
function M.get(c)
  local groups = {
    -- Semantic tokens link to the Tree-sitter captures, so both agree. Neovim's
    -- defaults already link most types; these are the ones it leaves out or
    -- links somewhere mistpine colors differently.
    ["@lsp.type.boolean"] = "@boolean",
    ["@lsp.type.builtinType"] = "@type.builtin",
    ["@lsp.type.comment"] = "@comment",
    ["@lsp.type.escapeSequence"] = "@string.escape",
    ["@lsp.type.formatSpecifier"] = "@punctuation.special",
    ["@lsp.type.generic"] = "@type",
    ["@lsp.type.lifetime"] = "@attribute",
    ["@lsp.type.modifier"] = "@keyword.modifier",
    ["@lsp.type.selfKeyword"] = "@variable.builtin",
    ["@lsp.type.selfTypeKeyword"] = "@variable.builtin",
    ["@lsp.type.typeAlias"] = "@type.definition",
    ["@lsp.type.unresolvedReference"] = { sp = c.error, undercurl = true },
    ["@lsp.mod.deprecated"] = "DiagnosticDeprecated",
    ["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
    ["@lsp.typemod.method.defaultLibrary"] = "@function.builtin",
    ["@lsp.typemod.variable.defaultLibrary"] = "@variable.builtin",
    ["@lsp.typemod.variable.injected"] = "@variable",
    ["@lsp.typemod.keyword.documentation"] = "@keyword",
    ["@lsp.typemod.function.builtin"] = "@function.builtin",

    -- References under the cursor (also snacks.nvim words, vim-illuminate)
    LspReferenceText = { bg = c.selection },
    LspReferenceRead = { bg = c.selection },
    LspReferenceWrite = { bg = c.selection, underline = true, sp = c.accent },
    LspReferenceTarget = "LspReferenceText",

    LspInlayHint = { fg = c.muted, bg = c.cursor_line },
    LspCodeLens = { fg = c.muted },
    LspCodeLensSeparator = { fg = c.border },
    LspSignatureActiveParameter = { bg = c.selection, bold = true },

    -- Diagnostics without a severity
    DiagnosticUnnecessary = { fg = c.muted },
    DiagnosticDeprecated = { sp = c.muted, strikethrough = true },
  }

  local severities = {
    Error = { c.error, c.virtual_error },
    Warn = { c.warning, c.virtual_warning },
    Info = { c.info, c.virtual_info },
    Hint = { c.hint, c.virtual_hint },
    Ok = { c.ok, c.virtual_ok },
  }
  for name, colors in pairs(severities) do
    local fg, bg = colors[1], colors[2]
    groups["Diagnostic" .. name] = { fg = fg }
    groups["DiagnosticSign" .. name] = { fg = fg }
    groups["DiagnosticFloating" .. name] = { fg = fg }
    groups["DiagnosticUnderline" .. name] = { sp = fg, undercurl = true }
    groups["DiagnosticVirtualText" .. name] = { fg = fg, bg = bg }
    groups["DiagnosticVirtualLines" .. name] = { fg = fg, bg = bg }
  end

  return groups
end

return M
