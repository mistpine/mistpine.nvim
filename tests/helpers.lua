local M = {}

function M.eq(actual, expected, msg)
  if not vim.deep_equal(actual, expected) then
    error(
      string.format("%sexpected %s, got %s", msg and (msg .. ": ") or "", vim.inspect(expected), vim.inspect(actual)),
      2
    )
  end
end

function M.ok(value, msg)
  if not value then
    error(msg or "expected a truthy value", 2)
  end
end

local function hex(n)
  return n and string.format("#%06x", n) or nil
end

--- A group's final attributes, links followed, colors as `#rrggbb`.
---@return table
function M.hl(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  hl.fg, hl.bg, hl.sp = hex(hl.fg), hex(hl.bg), hex(hl.sp)
  hl.cterm, hl.default = nil, nil
  return hl
end

--- Every defined group name.
function M.groups()
  local names = vim.tbl_keys(vim.api.nvim_get_hl(0, {}))
  table.sort(names)
  return names
end

--- Starts from Neovim's defaults and loads mistpine with `opts` passed to setup().
---@param opts? mistpine.Config
function M.load(opts)
  vim.cmd("highlight clear")
  vim.g.colors_name = nil
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = nil
  end
  require("mistpine").setup(opts)
  vim.cmd.colorscheme("mistpine")
end

--- Every color mistpine may produce: the spec's colors and the derived blends.
---@return table<string, true>
function M.allowed_colors()
  local c = require("mistpine").colors()
  local allowed = {}
  local function add(v)
    if type(v) == "string" and v:match("^#%x%x%x%x%x%x$") then
      allowed[v:lower()] = true
    elseif type(v) == "table" then
      for _, x in pairs(v) do
        add(x)
      end
    end
  end
  add(c)
  return allowed
end

return M
