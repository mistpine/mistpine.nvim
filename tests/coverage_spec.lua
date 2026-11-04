-- Nothing falls back to Neovim's default colorscheme, and nothing links nowhere.
local h = require("helpers")

--- Groups documented with a `*hl-Name*` tag in the running Neovim's help.
local function documented()
  local names = {}
  for _, file in ipairs(vim.fn.glob(vim.env.VIMRUNTIME .. "/doc/*.txt", false, true)) do
    for _, line in ipairs(vim.fn.readfile(file)) do
      for name in line:gmatch("%*hl%-([%w@.]+)%*") do
        names[name] = true
      end
    end
  end
  return names
end

return {
  {
    "every color comes from the palette or a spec blend",
    function()
      h.load()
      local allowed = h.allowed_colors()
      local bad = {}
      for _, name in ipairs(h.groups()) do
        local hl = h.hl(name)
        for _, attr in ipairs({ "fg", "bg", "sp" }) do
          if hl[attr] and not allowed[hl[attr]] then
            table.insert(bad, string.format("%s.%s = %s", name, attr, hl[attr]))
          end
        end
      end
      h.eq(bad, {})
    end,
  },
  {
    "every link points at a defined group",
    function()
      h.load()
      local all = vim.api.nvim_get_hl(0, {})
      local bad = {}
      for name, hl in pairs(all) do
        if hl.link and (not all[hl.link] or vim.tbl_isempty(all[hl.link])) then
          table.insert(bad, name .. " -> " .. hl.link)
        end
      end
      table.sort(bad)
      h.eq(bad, {})
    end,
  },
  {
    "every documented highlight group is set",
    function()
      h.load()
      local missing = {}
      for name in pairs(documented()) do
        local hl = vim.api.nvim_get_hl(0, { name = name, create = false })
        -- Help tags with typos or for groups Neovim no longer creates.
        -- User1..9 are the user's own status line colors.
        local skip = name == "FLoatShadowThrough" or name == "conceal" or name:match("^User%d")
        if not skip and vim.tbl_isempty(hl) then
          table.insert(missing, name)
        end
      end
      table.sort(missing)
      h.eq(missing, {})
    end,
  },
  {
    "every documented Tree-sitter capture has a color or a style",
    function()
      h.load()
      local doc = vim.fn.readfile(vim.env.VIMRUNTIME .. "/doc/treesitter.txt")
      local missing = {}
      for _, line in ipairs(doc) do
        local capture = line:match("^(@[%l][%w_.]*)%s")
        if capture then
          local hl = h.hl(capture)
          if vim.tbl_isempty(hl) then
            table.insert(missing, capture)
          end
        end
      end
      h.eq(missing, {})
    end,
  },
  {
    "every group Neovim colors by default is overridden",
    function()
      -- Groups with their own colors in `nvim --clean`, recorded before loading.
      vim.cmd("highlight clear")
      vim.g.colors_name = nil
      local defaults = {}
      for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
        if not hl.link and (hl.fg or hl.bg or hl.sp) then
          defaults[name] = hl
        end
      end
      h.load()
      local same = {}
      for name, hl in pairs(defaults) do
        if vim.deep_equal(vim.api.nvim_get_hl(0, { name = name }), hl) then
          table.insert(same, name)
        end
      end
      table.sort(same)
      h.eq(same, {})
    end,
  },
}
