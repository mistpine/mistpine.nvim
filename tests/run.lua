-- Runs tests/*_spec.lua: nvim --clean --headless -l tests/run.lua [filter]
--
-- Each spec file returns a list of { name, fn } pairs; a test fails when fn errors.

local root = vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")))
vim.opt.rtp:prepend(root)
package.path = root .. "/tests/?.lua;" .. package.path
vim.o.termguicolors = true

local filter = arg[1]
local passed, failed = 0, {}

for _, file in ipairs(vim.fn.glob(root .. "/tests/*_spec.lua", false, true)) do
  local spec = vim.fs.basename(file):gsub("_spec%.lua$", "")
  for _, case in ipairs(dofile(file)) do
    local name = spec .. ": " .. case[1]
    if not filter or name:find(filter, 1, true) then
      local ok, err = xpcall(case[2], debug.traceback)
      if ok then
        passed = passed + 1
        io.write("  ok    ", name, "\n")
      else
        table.insert(failed, { name, err })
        io.write("  FAIL  ", name, "\n")
      end
    end
  end
end

for _, f in ipairs(failed) do
  io.write("\n", f[1], "\n", f[2], "\n")
end
io.write(string.format("\n%d passed, %d failed (Neovim %s)\n", passed, #failed, tostring(vim.version())))
os.exit(#failed == 0 and 0 or 1)
