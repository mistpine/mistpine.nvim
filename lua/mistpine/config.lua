local M = {}

---@alias mistpine.Highlight vim.api.keyset.highlight|string A highlight definition, or the name of a group to link to

---@class mistpine.Config
---@field transparent? boolean Leave the editor background unset, so the terminal's shows through
---@field dim_inactive? boolean Give inactive windows the recessed panel background
---@field terminal_colors? boolean Set `g:terminal_color_0` … `g:terminal_color_15` for `:terminal`
---@field italic? boolean Use italics (comments, strings, …); turn off for fonts without them
---@field bold? boolean Use bold (functions, headings, …)
---@field plugins? table<string, boolean> Plugin integrations to load; `all` sets the default
---@field on_colors? fun(palette: mistpine.Palette) Change palette colors before anything is derived from them
---@field on_highlights? fun(highlights: table<string, mistpine.Highlight>, colors: mistpine.Colors) Change highlight groups before they are set
M.defaults = {
  transparent = false,
  dim_inactive = false,
  terminal_colors = true,
  italic = true,
  bold = true,
  plugins = { all = true },
  on_colors = function(_) end,
  on_highlights = function(_, _) end,
}

---@type mistpine.Config
M.options = vim.deepcopy(M.defaults)

---@param opts? mistpine.Config
function M.setup(opts)
  M.options = M.extend(opts)
end

--- The defaults merged with `opts`, without changing the stored options.
---@param opts? mistpine.Config
---@return mistpine.Config
function M.extend(opts)
  return vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
