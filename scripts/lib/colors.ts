/** mistpine's colors, read from the colorscheme itself so images never drift from it. */
import { execFileSync } from "node:child_process";
import { resolve } from "node:path";

export const ROOT = resolve(import.meta.dirname, "..", "..");

export interface Colors {
  palette: Record<string, string>;
  ansi: string[];
}

export function loadColors(): Colors {
  const lua =
    'local c = require("mistpine").colors(); io.write(vim.json.encode({ palette = c.palette, ansi = c.ansi }))';
  const out = execFileSync(
    "nvim",
    ["--clean", "--headless", "--cmd", `set rtp^=${ROOT}`, "-c", `lua ${lua}`, "-c", "qa"],
    { encoding: "utf8" },
  );
  return JSON.parse(out) as Colors;
}
