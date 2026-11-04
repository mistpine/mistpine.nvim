local h = require("helpers")

local function any(attr)
  for _, name in ipairs(h.groups()) do
    if vim.api.nvim_get_hl(0, { name = name })[attr] then
      return name
    end
  end
end

return {
  {
    "transparent leaves the editor background unset",
    function()
      h.load({ transparent = true })
      for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "FoldColumn", "BufferLineBufferSelected" }) do
        h.eq(h.hl(group).bg, nil, group)
      end
      h.eq(h.hl("NormalFloat").bg, "#071921")
    end,
  },
  {
    "dim_inactive recesses inactive windows",
    function()
      h.load()
      h.eq(h.hl("NormalNC").bg, "#0b1f27")
      h.load({ dim_inactive = true })
      h.eq(h.hl("NormalNC").bg, "#071921")
    end,
  },
  {
    "italic = false and bold = false drop those styles everywhere",
    function()
      h.load({ italic = false })
      h.eq(any("italic"), nil)
      h.ok(any("bold"), "bold should stay")
      h.load({ bold = false })
      h.eq(any("bold"), nil)
      h.ok(any("italic"), "italic should stay")
    end,
  },
  {
    "terminal_colors = false leaves terminal colors alone",
    function()
      h.load({ terminal_colors = false })
      h.eq(vim.g.terminal_color_0, nil)
    end,
  },
  {
    "on_colors changes a palette color and everything derived from it",
    function()
      h.load({
        on_colors = function(p)
          p.bg1 = "#000000"
          p.yellow = "#ffff00"
        end,
      })
      h.eq(h.hl("Normal").bg, "#000000")
      h.eq(h.hl("Type").fg, "#ffff00")
      local util = require("mistpine.util")
      h.eq(h.hl("Search").bg, util.mix("#000000", "#ffff00", 0.35))
    end,
  },
  {
    "on_highlights changes one group without touching groups that share its style",
    function()
      h.load({
        on_highlights = function(hl, c)
          hl.Comment.fg = c.fg2
          hl.Visual = { bg = c.bg4 }
        end,
      })
      h.eq(h.hl("Comment"), { fg = "#a7b0bb", italic = true })
      h.eq(h.hl("SpecialComment").fg, "#8796a0")
      h.eq(h.hl("Visual").bg, "#26414a")
    end,
  },
  {
    "plugins can be turned off one by one or all at once",
    function()
      h.load({ plugins = { telescope = false } })
      h.eq(vim.api.nvim_get_hl(0, { name = "TelescopeNormal" }), {})
      h.eq(h.hl("BlinkCmpLabelMatch").fg, "#c98b56")
      h.load({ plugins = { all = false, gitsigns = true } })
      h.eq(vim.api.nvim_get_hl(0, { name = "BlinkCmpLabelMatch" }), {})
      h.eq(h.hl("GitSignsAdd").fg, "#8a9a5b")
    end,
  },
  {
    "load(opts) applies options once, over setup()",
    function()
      h.load({ transparent = true })
      require("mistpine").load({ dim_inactive = true })
      h.eq(h.hl("Normal").bg, nil)
      h.eq(h.hl("NormalNC").bg, "#071921")
      vim.cmd.colorscheme("mistpine")
      h.eq(h.hl("NormalNC").bg, nil)
    end,
  },
}
