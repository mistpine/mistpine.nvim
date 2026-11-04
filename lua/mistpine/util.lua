local M = {}

---@param hex string `#rrggbb`
---@return number r, number g, number b in 0..1
function M.rgb(hex)
  local n = tonumber(hex:sub(2), 16)
  assert(n and #hex == 7, "not a #rrggbb color: " .. tostring(hex))
  return math.floor(n / 65536) / 255, (math.floor(n / 256) % 256) / 255, (n % 256) / 255
end

---@return string `#rrggbb`
function M.hex(r, g, b)
  local function byte(v)
    return math.floor(math.max(0, math.min(1, v)) * 255 + 0.5)
  end
  return string.format("#%02x%02x%02x", byte(r), byte(g), byte(b))
end

local function to_linear(c)
  if math.abs(c) <= 0.04045 then
    return c / 12.92
  end
  return (c < 0 and -1 or 1) * ((math.abs(c) + 0.055) / 1.055) ^ 2.4
end

local function from_linear(c)
  if math.abs(c) > 0.0031308 then
    return (c < 0 and -1 or 1) * (1.055 * math.abs(c) ^ (1 / 2.4) - 0.055)
  end
  return c * 12.92
end

local function cbrt(x)
  return x < 0 and -((-x) ^ (1 / 3)) or x ^ (1 / 3)
end

-- OKLab conversions with culori's constants, so blends match themes.utimura.io.
local function to_oklab(hex)
  local r, g, b = M.rgb(hex)
  r, g, b = to_linear(r), to_linear(g), to_linear(b)
  local l = cbrt(0.412221469470763 * r + 0.5363325372617348 * g + 0.0514459932675022 * b)
  local m = cbrt(0.2119034958178252 * r + 0.6806995506452344 * g + 0.1073969535369406 * b)
  local s = cbrt(0.0883024591900564 * r + 0.2817188391361215 * g + 0.6299787016738222 * b)
  return 0.210454268309314 * l + 0.7936177747023054 * m - 0.0040720430116193 * s,
    1.9779985324311684 * l - 2.4285922420485799 * m + 0.450593709617411 * s,
    0.0259040424655478 * l + 0.7827717124575296 * m - 0.8086757549230774 * s
end

local function from_oklab(L, a, b)
  local l = (L + 0.3963377773761749 * a + 0.2158037573099136 * b) ^ 3
  local m = (L - 0.1055613458156586 * a - 0.0638541728258133 * b) ^ 3
  local s = (L - 0.0894841775298119 * a - 1.2914855480194092 * b) ^ 3
  return M.hex(
    from_linear(4.0767416360759574 * l - 3.3077115392580616 * m + 0.2309699031821044 * s),
    from_linear(-1.2684379732850317 * l + 2.6097573492876887 * m - 0.3413193760026573 * s),
    from_linear(-0.0041960761386756 * l - 0.7034186179359362 * m + 1.7076146940746117 * s)
  )
end

--- Mixes two colors in OKLab: `amount = 0` returns `base`, `1` returns `color`.
--- This is the spec's `mix(base, color, amount)`.
---@param base string
---@param color string
---@param amount number 0..1
---@return string
function M.mix(base, color, amount)
  local l1, a1, b1 = to_oklab(base)
  local l2, a2, b2 = to_oklab(color)
  local t = math.max(0, math.min(1, amount))
  return from_oklab(l1 + (l2 - l1) * t, a1 + (a2 - a1) * t, b1 + (b2 - b1) * t)
end

--- WCAG 2 relative luminance.
function M.luminance(hex)
  local r, g, b = M.rgb(hex)
  return 0.2126 * to_linear(r) + 0.7152 * to_linear(g) + 0.0722 * to_linear(b)
end

--- WCAG 2 contrast ratio between two colors, 1..21.
function M.contrast(a, b)
  local la, lb = M.luminance(a), M.luminance(b)
  if la < lb then
    la, lb = lb, la
  end
  return (la + 0.05) / (lb + 0.05)
end

return M
