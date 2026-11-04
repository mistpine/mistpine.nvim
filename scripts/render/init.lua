-- A LazyVim setup for the README screenshots: telescope, blink.cmp, bufferline in
-- tab mode and a few extras, with mistpine loaded from this checkout.
--
-- Picker and completion are chosen in scripts/render/options.lua, which LazyVim
-- loads as `config.options`.
--
-- scripts/render.ts runs it with every XDG directory under .cache/render, so it
-- never reads or writes your own Neovim config, plugins or state. Language
-- servers come from $PATH (render.ts adds $MISTPINE_LSP_PATH): mason is off.

local root = assert(vim.env.MISTPINE_ROOT, "MISTPINE_ROOT is not set")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.lazyvim_check_order = false

local parsers = {
  "bash",
  "diff",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "python",
  "query",
  "regex",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = { colorscheme = "mistpine", news = { lazyvim = false, neovim = false } },
    },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },

    { dir = root, name = "mistpine.nvim", lazy = false, priority = 1000 },

    { "mason-org/mason.nvim", enabled = false },
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "folke/flash.nvim", enabled = false },
    { "linux-cultist/venv-selector.nvim", enabled = false },
    {
      "neovim/nvim-lspconfig",
      opts = function(_, opts)
        opts.inlay_hints = { enabled = true }
        for _, server in pairs(opts.servers or {}) do
          if type(server) == "table" then
            server.mason = false
          end
        end
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = parsers
      end,
    },
    {
      "folke/snacks.nvim",
      opts = { scroll = { enabled = false }, notifier = { timeout = 60000 } },
    },
    {
      "akinsho/bufferline.nvim",
      opts = { options = { mode = "tabs", show_buffer_close_icons = false, show_close_icon = false } },
    },
    {
      "b0o/incline.nvim",
      event = "BufReadPre",
      opts = {
        window = { margin = { vertical = 0, horizontal = 1 } },
        hide = { cursorline = true },
        render = function(props)
          local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local icon, hl = require("mini.icons").get("file", name)
          if vim.bo[props.buf].modified then
            name = "[+] " .. name
          end
          return { { icon, group = hl }, { " " }, { name } }
        end,
      },
    },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-telescope/telescope-file-browser.nvim" } },
    { "folke/zen-mode.nvim", cmd = "ZenMode" },
    { "brenoprata10/nvim-highlight-colors", event = "BufReadPre", opts = { render = "background" } },
  },
  install = { colorscheme = { "mistpine" } },
  checker = { enabled = false },
  change_detection = { enabled = false },
  rocks = { enabled = false },
})

vim.o.title = false
vim.o.shada = ""
vim.o.swapfile = false
