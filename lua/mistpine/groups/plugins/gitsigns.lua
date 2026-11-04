-- lewis6991/gitsigns.nvim
local M = {}

---@param c mistpine.Colors
function M.get(c)
  local kinds = {
    Add = { c.git_add, c.git_add_staged, "DiffAdd" },
    Change = { c.git_change, c.git_change_staged, "DiffChange" },
    Delete = { c.git_delete, c.git_delete_staged },
    Changedelete = { c.git_change, c.git_change_staged, "DiffChange" },
    Topdelete = { c.git_delete, c.git_delete_staged },
    Untracked = { c.git_add, c.git_add_staged, "DiffAdd" },
  }

  local groups = {
    GitSignsAddInline = { bg = c.inline_add },
    GitSignsChangeInline = { bg = c.inline_change },
    GitSignsDeleteInline = { bg = c.inline_delete },
    GitSignsAddLnInline = "GitSignsAddInline",
    GitSignsChangeLnInline = "GitSignsChangeInline",
    GitSignsDeleteLnInline = "GitSignsDeleteInline",
    GitSignsAddPreview = "DiffAdd",
    GitSignsDeletePreview = "DiffDelete",
    GitSignsDeleteVirtLn = "DiffDelete",
    GitSignsDeleteVirtLnInLine = "GitSignsDeleteInline",
    GitSignsVirtLnum = { fg = c.git_delete, bg = c.diff_delete },
    GitSignsNoEOLPreview = { fg = c.muted },
    GitSignsDiffStaged = { fg = c.muted },
    GitSignsCurrentLineBlame = { fg = c.muted },
  }

  for kind, colors in pairs(kinds) do
    local fg, staged, line = colors[1], colors[2], colors[3]
    for _, prefix in ipairs({ "GitSigns", "GitSignsStaged" }) do
      local color = prefix == "GitSigns" and fg or staged
      groups[prefix .. kind] = { fg = color }
      groups[prefix .. kind .. "Nr"] = { fg = color }
      groups[prefix .. kind .. "Cul"] = { fg = color }
      if line then
        groups[prefix .. kind .. "Ln"] = line
      end
    end
  end
  return groups
end

return M
