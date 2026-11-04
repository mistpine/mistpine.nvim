-- Loads real plugins, then mistpine, and checks what they draw with.
--
--   nvim --clean --headless -l tests/plugins/run.lua
--
-- Plugins come from $MISTPINE_PLUGINS (a directory of checkouts named like the
-- repos, such as lazy.nvim's; read only, missing plugins are skipped), else
-- they are cloned into .cache/plugins.
--
-- Fails when, after `:colorscheme mistpine`:
--   - a group resolves to a color that is not mistpine's (a plugin default left in place),
--   - mistpine defines a plugin group the plugin no longer registers (a stale name),
--   - lualine's `auto` theme does not pick up mistpine's.

local root =
  vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p"))))
package.path = root .. "/tests/?.lua;" .. package.path
local h = require("helpers")

local external = vim.env.MISTPINE_PLUGINS
local dir = external or (root .. "/.cache/plugins")
local plugins = {}
local problems = {}
local function problem(fmt, ...)
  table.insert(problems, string.format(fmt, ...))
end

vim.o.termguicolors = true
for _, spec in ipairs(dofile(root .. "/tests/plugins/list.lua")) do
  local path = dir .. "/" .. spec[1]:match("/(.+)$")
  if not vim.uv.fs_stat(path) and not external then
    io.write("cloning ", spec[1], "\n")
    local res = vim.system({ "git", "clone", "--quiet", "--depth=1", "https://github.com/" .. spec[1], path }):wait()
    assert(res.code == 0, res.stderr)
  end
  if vim.uv.fs_stat(path) then
    vim.opt.rtp:append(path)
    table.insert(plugins, spec)
  else
    io.write("skipping ", spec[1], " (not in ", dir, ")\n")
  end
end
vim.cmd("runtime! plugin/**/*.vim plugin/**/*.lua")

-- Neovim's default colorscheme, then each plugin registers its groups.
vim.cmd.colorscheme("default")
for _, spec in ipairs(plugins) do
  if spec[2] then
    local ok, err = pcall(spec[2])
    if not ok then
      problem("%s: setup failed: %s", spec[1], err)
    end
  end
end
vim.wait(200, function()
  return false
end)
local registered = vim.api.nvim_get_hl(0, {})

vim.opt.rtp:prepend(root)
vim.cmd.colorscheme("mistpine")
vim.wait(200, function()
  return false
end)

-- 1. Every color on screen is mistpine's. Some groups are colored per item on
-- purpose (a commit hash, a CSS color in the buffer, the backdrop of a float).
local per_item = {
  "^GitNvimBlameHash", -- git.nvim colors each commit by its hash
  "^NvimHighlightColors", -- nvim-highlight-colors previews colors written in the buffer
  "^BufferLineDevIcon", -- file icons in their own colors
  "^SnacksBackdrop_", -- snacks.nvim backdrops blend in black
  "^LazyBackdrop$",
  "^MasonBackdrop$",
  "^SnacksBackdrop$",
}
local allowed = h.allowed_colors()
for _, name in ipairs(h.groups()) do
  local skip = false
  for _, pattern in ipairs(per_item) do
    skip = skip or name:find(pattern) ~= nil
  end
  if not skip then
    local hl = h.hl(name)
    for _, attr in ipairs({ "fg", "bg", "sp" }) do
      if hl[attr] and not allowed[hl[attr]] then
        problem("%s.%s = %s is not a mistpine color", name, attr, hl[attr])
      end
    end
  end
end

-- 2. No stale plugin group names: each group mistpine defines for a plugin is
-- registered by it, or at least named in its source (some are only created
-- when a window opens).
local groups = require("mistpine.groups")
local c = require("mistpine").colors()
local options = require("mistpine.config").options
local mods = vim.tbl_keys(groups.plugins)
table.sort(mods)
for _, mod in ipairs(mods) do
  local path = dir .. "/" .. groups.plugins[mod]:match("/(.+)$")
  local names = vim.tbl_keys(require("mistpine.groups.plugins." .. mod).get(c, options))
  table.sort(names)
  for _, name in ipairs(names) do
    if not registered[name] or vim.tbl_isempty(registered[name]) then
      local found = vim.system({ "grep", "-rqF", name, path }):wait().code == 0
      if not found then
        problem("plugins.%s: %s is not used by %s", mod, name, groups.plugins[mod])
      end
    end
  end
end

-- 3. lualine's auto theme is mistpine's.
local mode = vim.api.nvim_get_hl(0, { name = "lualine_a_normal", link = false })
if not mode.bg or string.format("#%06x", mode.bg) ~= c.accent then
  problem("lualine_a_normal does not use mistpine's lualine theme: %s", vim.inspect(mode))
end

if #problems > 0 then
  io.write(table.concat(problems, "\n"), "\n\n", #problems, " problem(s)\n")
  os.exit(1)
end
io.write(string.format("%d plugins, %d groups: all colors are mistpine's\n", #plugins, #h.groups()))
os.exit(0)
