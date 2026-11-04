local M = {}

M.core = { "editor", "syntax", "treesitter", "lsp" }

--- Plugin integrations: the key used in `opts.plugins` → the plugin's repository.
M.plugins = {
  blink = "saghen/blink.cmp",
  bufferline = "akinsho/bufferline.nvim",
  flash = "folke/flash.nvim",
  gitsigns = "lewis6991/gitsigns.nvim",
  grug_far = "MagicDuck/grug-far.nvim",
  incline = "b0o/incline.nvim",
  lazy = "folke/lazy.nvim",
  mason = "mason-org/mason.nvim",
  mini = "nvim-mini/mini.icons",
  noice = "folke/noice.nvim",
  render_markdown = "MeanderingProgrammer/render-markdown.nvim",
  snacks = "folke/snacks.nvim",
  telescope = "nvim-telescope/telescope.nvim",
  trouble = "folke/trouble.nvim",
  which_key = "folke/which-key.nvim",
  zen_mode = "folke/zen-mode.nvim",
}

---@param opts mistpine.Config
---@param name string
local function enabled(opts, name)
  local plugins = opts.plugins or {}
  if plugins[name] ~= nil then
    return plugins[name]
  end
  return plugins.all ~= false
end

local STYLES = { "bold", "italic" }

--- All highlight groups for the given colors and options.
---@param c mistpine.Colors
---@param opts mistpine.Config
---@return table<string, mistpine.Highlight>
function M.get(c, opts)
  local groups = {}
  local function add(mod)
    for name, hl in pairs(require(mod).get(c, opts)) do
      -- Copies, so groups that share a style table can be changed one at a time.
      groups[name] = type(hl) == "table" and vim.deepcopy(hl) or hl
    end
  end
  for _, name in ipairs(M.core) do
    add("mistpine.groups." .. name)
  end
  local names = vim.tbl_keys(M.plugins)
  table.sort(names)
  for _, name in ipairs(names) do
    if enabled(opts, name) then
      add("mistpine.groups.plugins." .. name)
    end
  end

  for _, style in ipairs(STYLES) do
    if opts[style] == false then
      for _, hl in pairs(groups) do
        if type(hl) == "table" then
          hl[style] = nil
        end
      end
    end
  end

  if opts.on_highlights then
    opts.on_highlights(groups, c)
  end
  return groups
end

--- Sets the groups in the global namespace.
---@param groups table<string, mistpine.Highlight>
function M.apply(groups)
  for name, hl in pairs(groups) do
    if type(hl) == "string" then
      hl = { link = hl }
    end
    vim.api.nvim_set_hl(0, name, hl)
  end
end

return M
