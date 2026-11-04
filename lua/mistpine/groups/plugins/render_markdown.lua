-- MeanderingProgrammer/render-markdown.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  local groups = {
    RenderMarkdownCode = { bg = c.panel },
    RenderMarkdownCodeBorder = { bg = c.panel },
    RenderMarkdownCodeInline = { fg = c.syntax.string.fg, bg = c.cursor_line },
    RenderMarkdownCodeInfo = { fg = c.muted },
    RenderMarkdownBullet = { fg = c.orange },
    RenderMarkdownQuote = { fg = c.muted },
    RenderMarkdownDash = { fg = c.border },
    RenderMarkdownLink = { fg = c.syntax.link.fg },
    RenderMarkdownWikiLink = { fg = c.syntax.link.fg },
    RenderMarkdownTableHead = { fg = c.accent },
    RenderMarkdownTableRow = { fg = c.border },
    RenderMarkdownChecked = { fg = c.ok },
    RenderMarkdownUnchecked = { fg = c.muted },
    RenderMarkdownTodo = { fg = c.info },
    RenderMarkdownSign = "SignColumn",
    RenderMarkdownMath = { fg = c.syntax.constant.fg },
    RenderMarkdownIndent = { fg = c.nontext },
    RenderMarkdownHtmlComment = c.syntax.comment,
    RenderMarkdownSuccess = { fg = c.ok },
    RenderMarkdownInfo = { fg = c.info },
    RenderMarkdownHint = { fg = c.hint },
    RenderMarkdownWarn = { fg = c.warning },
    RenderMarkdownError = { fg = c.error },
  }
  -- Same level colors as the Tree-sitter headings, on a faint wash of each.
  local levels = { "green", "blue", "yellow", "cyan", "purple", "pink" }
  for i, name in ipairs(levels) do
    groups["RenderMarkdownH" .. i] = { fg = c[name], bold = true }
    groups["RenderMarkdownH" .. i .. "Bg"] = { fg = c[name], bg = c["heading_" .. name], bold = true }
  end
  return groups
end

return M
