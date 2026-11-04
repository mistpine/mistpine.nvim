-- folke/snacks.nvim: dashboard, notifier, picker and explorer, indent, input, words, …
--
-- snacks links most groups to standard ones. These override the links that
-- land on NonText (too dim for text in mistpine) or on colors that mean
-- something else here.
local M = {}

---@param c mistpine.Colors
function M.get(c)
  local groups = {
    -- Windows
    SnacksNormal = "NormalFloat",
    SnacksNormalNC = "NormalFloat",
    SnacksWinBar = { fg = c.subtle, bold = true },
    SnacksWinBarNC = { fg = c.muted },
    SnacksWinKey = { fg = c.orange },
    SnacksWinKeySep = { fg = c.muted },
    SnacksWinKeyDesc = { fg = c.fg },
    SnacksFooterKey = { fg = c.bg, bg = c.accent },
    SnacksFooterDesc = { fg = c.accent },
    SnacksTitle = "FloatTitle",
    SnacksFooter = "FloatFooter",

    -- Dashboard
    SnacksDashboardNormal = "Normal",
    SnacksDashboardHeader = { fg = c.cyan },
    SnacksDashboardIcon = { fg = c.accent },
    SnacksDashboardKey = { fg = c.orange },
    SnacksDashboardDesc = { fg = c.fg },
    SnacksDashboardFile = { fg = c.fg },
    SnacksDashboardDir = { fg = c.muted },
    SnacksDashboardFooter = { fg = c.muted },
    SnacksDashboardSpecial = { fg = c.purple },
    SnacksDashboardTitle = { fg = c.syntax.heading.fg, bold = true },

    -- Notifier
    SnacksNotifierMinimal = "NormalFloat",
    SnacksNotifierHistory = "NormalFloat",
    SnacksNotifierHistoryTitle = "FloatTitle",
    SnacksNotifierHistoryDateTime = { fg = c.muted },

    -- Indent guides and scope
    SnacksIndent = { fg = c.nontext },
    SnacksIndentBlank = { fg = c.nontext },
    SnacksIndentScope = { fg = c.dim },
    SnacksIndentChunk = { fg = c.dim },

    -- Input
    SnacksInputNormal = "NormalFloat",
    SnacksInputBorder = { fg = c.accent, bg = c.panel },
    SnacksInputTitle = { fg = c.accent, bg = c.panel, bold = true },
    SnacksInputIcon = { fg = c.accent },
    SnacksInputPrompt = { fg = c.accent },

    -- Zen, dim, scratch, image
    SnacksZenIcon = { fg = c.yellow },
    SnacksDim = { fg = c.dim },
    SnacksScratchTitle = "FloatTitle",
    SnacksImageMath = { fg = c.syntax.constant.fg },
    SnacksImageLoading = { fg = c.muted },

    -- Picker and explorer
    SnacksPickerPrompt = { fg = c.accent },
    SnacksPickerInputSearch = { fg = c.orange },
    SnacksPickerMatch = { fg = c.orange, bold = true },
    SnacksPickerSearch = "Search",
    SnacksPickerSelected = { fg = c.yellow },
    SnacksPickerUnselected = { fg = c.muted },
    SnacksPickerSpinner = { fg = c.accent },
    SnacksPickerTotals = { fg = c.muted },
    SnacksPickerDir = { fg = c.muted },
    SnacksPickerPathHidden = { fg = c.muted },
    SnacksPickerPathIgnored = { fg = c.dim },
    SnacksPickerDimmed = { fg = c.muted },
    SnacksPickerBufFlags = { fg = c.muted },
    SnacksPickerKeymapRhs = { fg = c.muted },
    SnacksPickerTree = { fg = c.border },
    SnacksPickerIcon = { fg = c.accent },
    SnacksPickerToggle = { fg = c.bg, bg = c.accent },
    SnacksPickerGitStatusIgnored = { fg = c.dim },
    SnacksPickerGitStatusUntracked = { fg = c.muted },
    SnacksPickerGitStatusModified = { fg = c.git_change },
    SnacksPickerGitStatusStaged = { fg = c.git_add },
    SnacksPickerPickWin = { fg = c.bg, bg = c.pink, bold = true },
    SnacksPickerPickWinCurrent = { fg = c.bg, bg = c.orange, bold = true },
  }

  -- Notifications: the level's color on the border, icon and title.
  local levels = { Error = c.error, Warn = c.warning, Info = c.info, Debug = c.muted, Trace = c.dim }
  for level, color in pairs(levels) do
    groups["SnacksNotifier" .. level] = "NormalFloat"
    groups["SnacksNotifierBorder" .. level] = { fg = color, bg = c.panel }
    groups["SnacksNotifierIcon" .. level] = { fg = color }
    groups["SnacksNotifierTitle" .. level] = { fg = color, bold = true }
    groups["SnacksNotifierFooter" .. level] = { fg = color }
  end

  return groups
end

return M
