/**
 * Renders the README screenshots from a real Neovim: a LazyVim setup
 * (scripts/render/init.lua) runs under `nvim --embed`, scripts/render/ui.ts
 * records the screen, and Chromium draws it.
 *
 *   pnpm render [scene…]
 *
 * Everything Neovim touches lives in .cache/render (plugins, parsers, state).
 * The first run clones LazyVim and its plugins and compiles a few Tree-sitter
 * parsers, so it needs network access, git, a C compiler and `tree-sitter`.
 *
 *   MISTPINE_LSP_PATH  dir with lua-language-server, pyright and ruff
 *                      (default: ~/.local/share/nvim/mason/bin)
 *   CHROMIUM           browser executable (default: playwright's)
 *   FONTS_DIR          JetBrains Mono and Symbols Nerd Font Mono
 *                      (default: .cache/fonts, downloaded when missing)
 */
import { execFileSync } from "node:child_process";
import {
  cpSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from "node:fs";
import { homedir, tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright-core";
import { type Fonts, type Frame, screenHtml } from "./render/page.ts";
import { Nvim } from "./render/ui.ts";

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const CACHE = join(ROOT, ".cache", "render");
const OUT = join(ROOT, "assets", "screenshots");
const PARSERS = [
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
];

const lspPath =
  process.env.MISTPINE_LSP_PATH ?? join(homedir(), ".local", "share", "nvim", "mason", "bin");
const env: NodeJS.ProcessEnv = {
  ...process.env,
  MISTPINE_ROOT: ROOT,
  XDG_CONFIG_HOME: join(CACHE, "config"),
  XDG_DATA_HOME: join(CACHE, "data"),
  XDG_STATE_HOME: join(CACHE, "state"),
  XDG_CACHE_HOME: join(CACHE, "cache"),
  NVIM_APPNAME: "nvim",
  PATH: `${lspPath}:${process.env.PATH ?? ""}`,
  TERM: "xterm-256color",
  COLORTERM: "truecolor",
  TZ: "UTC",
};

// ---------------------------------------------------------------- setup

function bootstrap() {
  const init = join(CACHE, "config", "nvim", "init.lua");
  mkdirSync(dirname(init), { recursive: true });
  writeFileSync(init, 'dofile(vim.env.MISTPINE_ROOT .. "/scripts/render/init.lua")\n');
  const options = join(dirname(init), "lua", "config", "options.lua");
  mkdirSync(dirname(options), { recursive: true });
  writeFileSync(options, 'dofile(vim.env.MISTPINE_ROOT .. "/scripts/render/options.lua")\n');
  const nvim = (...args: string[]) =>
    execFileSync("nvim", ["--headless", ...args, "+qa"], {
      env,
      stdio: "inherit",
      timeout: 900_000,
    });
  // Installs whatever the config lists that is missing (a no-op once set up).
  nvim("+Lazy! install");
  const parsers = join(CACHE, "data", "nvim", "site", "parser");
  if (PARSERS.some((p) => !existsSync(join(parsers, `${p}.so`)))) {
    nvim(
      "-c",
      `lua require("nvim-treesitter").install(${JSON.stringify(PARSERS).replace(/^\[/, "{").replace(/\]$/, "}")}):wait(800000)`,
    );
  }
}

function fonts(): Fonts {
  const dir = process.env.FONTS_DIR ?? join(ROOT, ".cache", "fonts");
  const fonts = {
    regular: join(dir, "fonts", "variable", "JetBrainsMono[wght].ttf"),
    italic: join(dir, "fonts", "variable", "JetBrainsMono-Italic[wght].ttf"),
    symbols: join(dir, "SymbolsNerdFontMono-Regular.ttf"),
  };
  if (!existsSync(fonts.regular) || !existsSync(fonts.symbols)) {
    mkdirSync(dir, { recursive: true });
    const get = (url: string, file: string) =>
      execFileSync("curl", ["-fsSLo", join(dir, file), url]);
    get(
      "https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip",
      "jbm.zip",
    );
    execFileSync("unzip", ["-qo", "jbm.zip", "fonts/variable/*"], { cwd: dir });
    get(
      "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/NerdFontsSymbolsOnly.tar.xz",
      "nf.tar.xz",
    );
    execFileSync("tar", ["-xf", "nf.tar.xz"], { cwd: dir });
  }
  return fonts;
}

/** The sample project in a fresh git repo, with uncommitted edits for gitsigns. */
function workspace(): string {
  const dir = mkdtempSync(join(tmpdir(), "mistpine-render-"));
  cpSync(join(ROOT, "scripts", "render", "sample"), dir, { recursive: true });
  const git = (...args: string[]) => execFileSync("git", args, { cwd: dir, stdio: "ignore" });
  git("init", "-q", "-b", "main");
  git("-c", "user.name=mistpine", "-c", "user.email=mistpine@example.com", "add", ".");
  git("-c", "user.name=mistpine", "-c", "user.email=mistpine@example.com", "commit", "-qm", "init");
  const file = join(dir, "fog", "forecast.py");
  const edited = readFileSync(file, "utf8")
    .replace('    """Keeps the latest reading per station and reports the foggy ones."""\n\n', "")
    .replace(
      "        if reading.humidity < 0.95",
      "        # TODO: skip readings older than max_age\n        if reading.humidity < 0.95",
    )
    .replace("and r.visibility < FOG_LIMIT", "and r.visiblity < FOG_LIMIT");
  writeFileSync(file, edited);
  return dir;
}

// ---------------------------------------------------------------- scenes

interface Scene {
  title: string;
  args: string[];
  cols?: number;
  rows?: number;
  cursor?: boolean;
  run: (nvim: Nvim) => Promise<void>;
}

const wait = (ms: number) => new Promise((r) => setTimeout(r, ms));

/** Types one key at a time, so completion menus react as they would to a person. */
async function type(nvim: Nvim, text: string, delay = 40) {
  for (const ch of text) {
    await nvim.input(ch === "<" ? "<lt>" : ch);
    await wait(delay);
  }
}

/** Waits for git signs and, unless `diagnostics` is false, for both servers' diagnostics. */
async function ready(nvim: Nvim, diagnostics = true) {
  await nvim.lua(
    `local want = ...
    vim.wait(30000, function()
      local signs = #vim.api.nvim_buf_get_extmarks(0, -1, 0, -1, { type = "sign" }) > 0
      local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) > 0
      local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }) > 0
      return signs and (not want or (errors and warnings))
    end, 100)`,
    diagnostics,
  );
}

const scenes: Record<string, Scene> = {
  preview: {
    title: "nvim · fog/forecast.py",
    args: ["fog/forecast.py"],
    rows: 41,
    async run(nvim) {
      await ready(nvim);
      await nvim.command("tabedit README.md");
      await nvim.command("tabedit tests/test_forecast.py");
      await nvim.command("tabfirst");
      await wait(1500);
      await nvim.lua('vim.fn.search("reading: Reading")');
    },
  },
  completion: {
    title: "nvim · fog/forecast.py",
    args: ["fog/forecast.py"],
    rows: 30,
    async run(nvim) {
      await ready(nvim);
      await nvim.lua('vim.fn.search("now = now or")');
      await nvim.input("o");
      await wait(300);
      await type(nvim, "stale = self.");
      await wait(2500);
    },
  },
  telescope: {
    title: "nvim · find files",
    args: ["fog/forecast.py"],
    rows: 30,
    async run(nvim) {
      await ready(nvim, false);
      await nvim.input("<Space><Space>");
      await wait(1200);
      await nvim.input("fore");
      await wait(1500);
    },
  },
  whichkey: {
    title: "nvim · which-key",
    args: ["fog/forecast.py"],
    rows: 30,
    async run(nvim) {
      await ready(nvim, false);
      await nvim.input("<Space>");
      await wait(1500);
    },
  },
  markdown: {
    title: "nvim · README.md",
    args: ["README.md"],
    rows: 36,
    async run(nvim) {
      await wait(1500);
      await nvim.lua("vim.api.nvim_win_set_cursor(0, { 2, 0 })");
      await wait(800);
    },
  },
  dashboard: {
    title: "nvim",
    args: [],
    rows: 30,
    cursor: false,
    async run() {
      await wait(1500);
    },
  },
  cmdline: {
    title: "nvim · fog/forecast.py",
    args: ["fog/forecast.py"],
    rows: 30,
    async run(nvim) {
      await ready(nvim);
      await wait(4000); // let the language server progress messages fade
      await type(nvim, ":colorscheme mi", 80);
      await wait(1500);
    },
  },
};

// ---------------------------------------------------------------- main

const chrome = (): Frame["chrome"] => {
  const out = execFileSync(
    "nvim",
    [
      "--clean",
      "--headless",
      "--cmd",
      `set rtp^=${ROOT}`,
      "-c",
      'lua local c = require("mistpine").colors(); io.write(table.concat({ c.bg0, c.bg4, c.fg1, c.red, c.yellow, c.green }, " "))',
      "-c",
      "qa",
    ],
    { encoding: "utf8" },
  );
  return out.trim().split(" ") as Frame["chrome"];
};

const wanted = process.argv.slice(2);
const names = wanted.length ? wanted : Object.keys(scenes);
bootstrap();
const fontFiles = fonts();
const frameColors = chrome();
mkdirSync(OUT, { recursive: true });
const browser = await chromium.launch({ executablePath: process.env.CHROMIUM || undefined });
const dir = workspace();
try {
  for (const name of names) {
    const scene = scenes[name];
    if (!scene) throw new Error(`no scene "${name}": ${Object.keys(scenes).join(", ")}`);
    const nvim = new Nvim(scene.args, {
      cwd: dir,
      env,
      cols: scene.cols ?? 120,
      rows: scene.rows ?? 34,
    });
    await nvim.attach();
    await nvim.settle(600, 8000);
    await scene.run(nvim);
    await nvim.settle(500, 8000);
    if (process.env.RENDER_DEBUG) {
      console.log(
        await nvim.lua(
          "return vim.inspect(vim.tbl_map(function(d) return { d.severity, d.lnum, d.source } end, vim.diagnostic.get(0)))",
        ),
      );
      const attrs = Object.fromEntries(nvim.screen.attrs);
      writeFileSync(
        join(CACHE, `${name}.json`),
        JSON.stringify({ cells: nvim.screen.cells, attrs }),
      );
    }
    const html = screenHtml(
      nvim.screen,
      fontFiles,
      { title: scene.title, chrome: frameColors },
      scene.cursor ?? true,
    );
    await nvim.quit();
    const page = await browser.newPage({ deviceScaleFactor: 2 });
    await page.setContent(html, { waitUntil: "load" });
    await page.evaluate(() => document.fonts.ready);
    const file =
      name === "preview" ? join(ROOT, "assets", "preview.png") : join(OUT, `${name}.png`);
    await page.locator("body").screenshot({ path: file, omitBackground: true });
    await page.close();
    console.log(`wrote ${file.slice(ROOT.length + 1)}`);
  }
} finally {
  await browser.close();
  rmSync(dir, { recursive: true, force: true });
}
