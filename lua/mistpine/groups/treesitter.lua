-- Tree-sitter captures (`:h treesitter-highlight-groups`).
local M = {}

---@param c mistpine.Colors
---@param opts mistpine.Config
function M.get(c, opts)
  local s = c.syntax
  local bg = opts.transparent and "NONE" or c.bg

  local function with(style, extra)
    return vim.tbl_extend("force", {}, style, extra)
  end

  local groups = {
    ["@variable"] = s.variable,
    ["@variable.builtin"] = s.builtin,
    ["@variable.parameter"] = s.parameter,
    ["@variable.parameter.builtin"] = s.builtin,
    ["@variable.member"] = s.property,

    ["@constant"] = s.constant,
    ["@constant.builtin"] = s.constant,
    ["@constant.macro"] = s.macro,

    ["@module"] = s.namespace,
    ["@module.builtin"] = s.builtin,
    ["@label"] = s.keyword,

    ["@string"] = s.string,
    ["@string.documentation"] = s.string,
    ["@string.regexp"] = s.regex,
    ["@string.escape"] = s.escape,
    ["@string.special"] = s.escape,
    ["@string.special.symbol"] = s.constant,
    ["@string.special.path"] = s.string,
    ["@string.special.url"] = s.link,

    ["@character"] = s.string,
    ["@character.special"] = s.escape,

    ["@boolean"] = s.boolean,
    ["@number"] = s.number,
    ["@number.float"] = s.number,

    ["@type"] = s.type,
    ["@type.builtin"] = s.type,
    ["@type.definition"] = s.type,

    ["@attribute"] = s.attribute,
    ["@attribute.builtin"] = s.builtin,
    ["@property"] = s.property,

    ["@function"] = s["function"],
    ["@function.builtin"] = s.builtin,
    ["@function.call"] = s["function"],
    ["@function.macro"] = s.macro,
    ["@function.method"] = s.method,
    ["@function.method.call"] = s.method,
    ["@constructor"] = s.type,
    ["@operator"] = s.operator,

    ["@keyword"] = s.keyword,
    ["@keyword.coroutine"] = s.control,
    ["@keyword.function"] = s.keyword,
    ["@keyword.operator"] = s.keyword,
    ["@keyword.import"] = s.keyword,
    ["@keyword.type"] = s.keyword,
    ["@keyword.modifier"] = s.keyword,
    ["@keyword.repeat"] = s.control,
    ["@keyword.return"] = s.control,
    ["@keyword.debug"] = s.builtin,
    ["@keyword.exception"] = s.control,
    ["@keyword.conditional"] = s.control,
    ["@keyword.conditional.ternary"] = s.operator,
    ["@keyword.directive"] = s.macro,
    ["@keyword.directive.define"] = s.macro,

    ["@punctuation"] = s.punctuation,
    ["@punctuation.delimiter"] = s.punctuation,
    ["@punctuation.bracket"] = s.punctuation,
    ["@punctuation.special"] = s.escape,

    ["@comment"] = s.comment,
    ["@comment.documentation"] = s.comment,
    ["@comment.error"] = { fg = c.bg, bg = c.error, bold = true },
    ["@comment.warning"] = { fg = c.bg, bg = c.warning, bold = true },
    ["@comment.todo"] = { fg = c.bg, bg = c.info, bold = true },
    ["@comment.note"] = { fg = c.bg, bg = c.hint, bold = true },

    ["@markup"] = { fg = c.fg },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = with(s.heading, { bold = true }),
    ["@markup.quote"] = { fg = c.muted, italic = true },
    ["@markup.math"] = s.constant,
    ["@markup.link"] = s.link,
    ["@markup.link.label"] = with(s.link, { underline = false }),
    ["@markup.link.url"] = with(s.link, { underline = true }),
    ["@markup.raw"] = { fg = s.string.fg },
    ["@markup.raw.block"] = { fg = c.fg },
    ["@markup.list"] = { fg = c.orange },
    ["@markup.list.checked"] = { fg = c.ok },
    ["@markup.list.unchecked"] = { fg = c.muted },
    -- The `===` and `---` rules under vimdoc headings: hide the text, keep a line.
    ["@markup.heading.1.delimiter.vimdoc"] = { fg = c.bg, bg = bg, sp = c.border, underdouble = true, nocombine = true },
    ["@markup.heading.2.delimiter.vimdoc"] = { fg = c.bg, bg = bg, sp = c.border, underline = true, nocombine = true },

    ["@tag"] = s.tag,
    ["@tag.builtin"] = s.tag,
    ["@tag.attribute"] = s.attribute,
    ["@tag.delimiter"] = s.punctuation,

    ["@diff.plus"] = { fg = c.git_add },
    ["@diff.minus"] = { fg = c.git_delete },
    ["@diff.delta"] = { fg = c.git_change },

    ["@none"] = {},
    ["@conceal"] = { fg = c.muted },

    -- Lua table braces are captured as constructors: keep them punctuation.
    ["@constructor.lua"] = s.punctuation,
  }

  -- Heading levels step through the accents, starting from the spec's heading green.
  local levels = { "green", "blue", "yellow", "cyan", "purple", "pink" }
  for i, name in ipairs(levels) do
    groups["@markup.heading." .. i] = { fg = c[name], bold = true }
  end

  return groups
end

return M
