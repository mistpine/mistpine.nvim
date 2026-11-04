local config = require("mistpine.config")

local M = {}

--- Stores options for the next `:colorscheme mistpine`. Optional: without it the
--- colorscheme loads with the defaults.
---@param opts? mistpine.Config
function M.setup(opts)
  config.setup(opts)
end

--- Applies the colorscheme. `:colorscheme mistpine` calls this.
---@param opts? mistpine.Config Options for this load only, merged over the ones from `setup()`
function M.load(opts)
  opts = M.options(opts)

  if vim.g.colors_name then
    vim.cmd("highlight clear")
  end
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  -- mistpine is dark only (a no-op when 'background' already is dark). Clear
  -- `colors_name` first so the change doesn't reload the previous colorscheme.
  vim.g.colors_name = nil
  vim.o.background = "dark"
  vim.g.colors_name = "mistpine"

  local c = require("mistpine.colors").get(opts)
  local groups = require("mistpine.groups")
  groups.apply(groups.get(c, opts))

  if opts.terminal_colors then
    for i, hex in ipairs(c.ansi) do
      vim.g["terminal_color_" .. (i - 1)] = hex
    end
  end
end

--- The resolved colors, for statuslines and other configs that want to match.
---@param opts? mistpine.Config Merged over the ones from `setup()`
---@return mistpine.Colors
function M.colors(opts)
  return require("mistpine.colors").get(M.options(opts))
end

--- The options from `setup()`, with `opts` merged over them.
---@param opts? mistpine.Config
---@return mistpine.Config
function M.options(opts)
  if not opts then
    return config.options
  end
  return vim.tbl_deep_extend("force", vim.deepcopy(config.options), opts)
end

return M
