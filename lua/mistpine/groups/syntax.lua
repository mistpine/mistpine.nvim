-- Legacy syntax groups (`:h group-name`), still used by Vim syntax files,
-- plugins and as fallbacks for Tree-sitter captures.
local M = {}

---@param c mistpine.Colors
function M.get(c)
  local s = c.syntax

  return {
    Comment = s.comment,
    SpecialComment = s.comment,

    Constant = s.constant,
    String = s.string,
    Character = s.string,
    Number = s.number,
    Float = s.number,
    Boolean = s.boolean,

    Identifier = s.variable,
    Function = s["function"],

    Statement = s.keyword,
    Keyword = s.keyword,
    Label = s.keyword,
    StorageClass = s.keyword,
    Include = s.keyword,
    Conditional = s.control,
    Repeat = s.control,
    Exception = s.control,
    Operator = s.operator,

    PreProc = s.macro,
    Define = s.macro,
    Macro = s.macro,
    PreCondit = s.macro,

    Type = s.type,
    Structure = s.type,
    Typedef = s.type,

    Regexp = s.regex, -- Neovim 0.13
    Special = s.escape,
    SpecialChar = s.escape,
    Tag = s.tag,
    Delimiter = s.punctuation,
    Debug = { fg = c.orange },

    Underlined = { fg = s.link.fg, underline = true },
    Error = { fg = c.error },
    Todo = { fg = c.bg, bg = c.info, bold = true },

    -- Vim help files
    helpHeader = { fg = s.heading.fg, bold = true },
    helpSectionDelim = { fg = c.border },
    helpHyperTextJump = { fg = s.link.fg, underline = true },
    helpHyperTextEntry = { fg = s.tag.fg },
    helpOption = { fg = c.cyan },
    helpExample = { fg = s.string.fg },

    -- Git commit messages
    gitcommitSummary = { fg = c.fg },
    gitcommitOverflow = { fg = c.warning },
    gitcommitBranch = { fg = c.purple },
    gitcommitSelectedFile = { fg = c.git_add },
    gitcommitDiscardedFile = { fg = c.git_delete },
    gitcommitUntrackedFile = { fg = c.muted },
  }
end

return M
