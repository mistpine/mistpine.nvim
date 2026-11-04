local h = require("helpers")

return {
  {
    "loads with :colorscheme",
    function()
      h.load()
      h.eq(vim.g.colors_name, "mistpine")
      h.eq(vim.o.background, "dark")
      h.eq(h.hl("Normal"), { fg = "#c4c9d0", bg = "#0b1f27" })
    end,
  },
  {
    "sets the 16 terminal colors from the spec",
    function()
      h.load()
      local spec = require("mistpine.palette")
      for i, e in ipairs(spec.ansi) do
        h.eq(vim.g["terminal_color_" .. (i - 1)], e[1], "terminal_color_" .. (i - 1))
      end
    end,
  },
  {
    "switches 'background' to dark without reloading the previous colorscheme",
    function()
      vim.cmd.colorscheme("default")
      vim.o.background = "light"
      local reloaded = 0
      local id = vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function(ev)
          reloaded = reloaded + (ev.match == "default" and 1 or 0)
        end,
      })
      vim.cmd.colorscheme("mistpine")
      vim.api.nvim_del_autocmd(id)
      h.eq(vim.o.background, "dark")
      h.eq(reloaded, 0)
      h.eq(h.hl("Normal").bg, "#0b1f27")
    end,
  },
  {
    "setting 'background' to light turns it off, as Vim does for dark-only schemes",
    function()
      h.load()
      vim.o.background = "light"
      h.eq(vim.g.colors_name, nil)
      h.eq(vim.o.background, "light")
      h.load()
      h.eq(vim.o.background, "dark")
    end,
  },
  {
    "reloading gives the same groups",
    function()
      h.load()
      local first = vim.api.nvim_get_hl(0, {})
      vim.cmd.colorscheme("mistpine")
      h.eq(vim.api.nvim_get_hl(0, {}), first)
    end,
  },
  {
    "another colorscheme replaces it cleanly",
    function()
      h.load()
      vim.cmd.colorscheme("default")
      h.eq(vim.g.colors_name, "default")
      h.ok(h.hl("Normal").bg ~= "#0b1f27", "Normal should no longer use mistpine's background")
      h.load()
      h.eq(h.hl("Normal").bg, "#0b1f27")
    end,
  },
  {
    "lualine theme has every mode and section",
    function()
      h.load()
      package.loaded["lualine.themes.mistpine"] = nil
      local theme = require("lualine.themes.mistpine")
      for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }) do
        for _, section in ipairs({ "a", "b", "c" }) do
          local s = theme[mode] and theme[mode][section]
          h.ok(s, mode .. "." .. section .. " is missing")
          h.ok(s.fg:match("^#%x+$") and s.bg:match("^#%x+$"), mode .. "." .. section .. " needs fg and bg")
        end
      end
      h.eq(theme.normal.a.bg, require("mistpine").colors().accent)
    end,
  },
  {
    "exposes the resolved colors",
    function()
      local c = require("mistpine").colors()
      h.eq(c.bg1, "#0b1f27")
      h.eq(c.syntax.comment, { fg = "#8796a0", italic = true })
      h.eq(c.ui.searchBg, "#464b3c")
      h.eq(#c.ansi, 16)
    end,
  },
}
