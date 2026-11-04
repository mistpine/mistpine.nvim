/**
 * Draws a Neovim screen as HTML: every run of cells is placed on the exact
 * cell grid, so glyphs from fallback fonts (Nerd Font icons) cannot drift.
 */
import { readFileSync } from "node:fs";
import type { Attr, Screen } from "./ui.ts";

export interface Fonts {
  regular: string;
  italic: string;
  symbols: string;
}

export interface Frame {
  title: string;
  /** Window chrome colors: [panel, border, title text, dot 1, dot 2, dot 3]. */
  chrome: [string, string, string, string, string, string];
}

const SIZE = 15; // px
const CW = SIZE * 0.6; // JetBrains Mono advances are 600/1000 em
const LH = 24; // px

const hex = (n: number) => `#${n.toString(16).padStart(6, "0")}`;
const esc = (s: string) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");

/** Text the primary font draws at exactly one cell: ASCII, Latin and box drawing. */
const simple = (t: string) => /^[ -ɏ─-▟]$/.test(t);

function style(attr: Attr, screen: Screen, cursor = false): string {
  const d = screen.defaults;
  let fg = attr.foreground ?? d.fg;
  let bg = attr.background ?? d.bg;
  if (Boolean(attr.reverse) !== cursor) [fg, bg] = [bg, fg];
  const css = [`color:${hex(fg)}`];
  if (bg !== d.bg || attr.reverse || cursor) css.push(`background:${hex(bg)}`);
  if (attr.bold) css.push("font-weight:700");
  if (attr.italic) css.push("font-style:italic");
  const lines: string[] = [];
  let line = "";
  if (attr.undercurl) line = "wavy";
  else if (attr.underdouble) line = "double";
  else if (attr.underdotted) line = "dotted";
  else if (attr.underdashed) line = "dashed";
  else if (attr.underline) line = "solid";
  if (line) lines.push("underline");
  if (attr.strikethrough) lines.push("line-through");
  if (lines.length) {
    css.push(
      `text-decoration:${lines.join(" ")} ${line || "solid"} ${hex(attr.special ?? (line ? d.sp : fg))}`,
      "text-underline-offset:3px",
    );
  }
  return css.join(";");
}

function span(row: number, col: number, width: number, text: string, css: string, cls = "") {
  return `<span class="c${cls}" style="top:${row * LH}px;left:${col * CW}px;width:${width * CW}px;${css}">${esc(text)}</span>`;
}

export function screenHtml(
  screen: Screen,
  fonts: Fonts,
  frame: Frame,
  showCursor: boolean,
): string {
  const parts: string[] = [];
  screen.cells.forEach((cells, r) => {
    let c = 0;
    while (c < cells.length) {
      const cell = cells[c];
      if (!cell) break;
      const attr = screen.attrs.get(cell.hl) ?? {};
      if (!simple(cell.text)) {
        const wide = cells[c + 1]?.text === "";
        const width = wide ? 2 : 1;
        if (cell.text !== "") parts.push(span(r, c, width, cell.text, style(attr, screen), " g"));
        c += width;
        continue;
      }
      let text = cell.text;
      let end = c + 1;
      while (end < cells.length) {
        const next = cells[end];
        if (!next || next.hl !== cell.hl || !simple(next.text)) break;
        text += next.text;
        end++;
      }
      parts.push(span(r, c, end - c, text, style(attr, screen)));
      c = end;
    }
  });

  if (showCursor) {
    const { row, col } = screen.cursor;
    const cell = screen.cells[row]?.[col];
    const mode = screen.mode ?? {};
    const own = mode.attr_id ? screen.attrs.get(mode.attr_id) : undefined;
    const cellAttr = screen.attrs.get(cell?.hl ?? 0) ?? {};
    const colors =
      own?.background !== undefined ? { ...cellAttr, ...own, reverse: false } : cellAttr;
    if (mode.cursor_shape === "vertical" || mode.cursor_shape === "horizontal") {
      const color = hex(own?.background ?? screen.defaults.fg);
      const pct = (mode.cell_percentage ?? 25) / 100;
      const box =
        mode.cursor_shape === "vertical"
          ? `top:${row * LH}px;left:${col * CW}px;width:${Math.max(2, CW * pct)}px;height:${LH}px`
          : `top:${(row + 1) * LH - LH * pct}px;left:${col * CW}px;width:${CW}px;height:${LH * pct}px`;
      parts.push(`<div class="cursor" style="${box};background:${color}"></div>`);
    } else if (cell) {
      const css =
        own?.background !== undefined
          ? style({ ...colors, reverse: true }, screen, false)
          : style(colors, screen, true);
      parts.push(span(row, col, 1, cell.text || " ", css, simple(cell.text) ? "" : " g"));
    }
  }

  const [panel, border, titleFg, ...dots] = frame.chrome;
  // Inlined: Chromium will not load file:// fonts into a page set with setContent().
  const url = (p: string) => `data:font/ttf;base64,${readFileSync(p).toString("base64")}`;
  return `<!doctype html>
<html><head><meta charset="utf-8"><style>
@font-face { font-family: "JetBrains Mono"; src: url("${url(fonts.regular)}"); font-weight: 100 800; font-style: normal; }
@font-face { font-family: "JetBrains Mono"; src: url("${url(fonts.italic)}"); font-weight: 100 800; font-style: italic; }
@font-face { font-family: "Symbols Nerd Font Mono"; src: url("${url(fonts.symbols)}"); }
* { box-sizing: border-box; margin: 0; }
html, body { background: transparent; }
body { padding: 40px; width: max-content; }
.window {
  border-radius: 14px; overflow: hidden; background: ${hex(screen.defaults.bg)};
  box-shadow: 0 0 0 1px ${border}, 0 28px 64px -12px rgba(2, 10, 14, 0.55), 0 8px 20px -8px rgba(2, 10, 14, 0.4);
}
.titlebar { height: 40px; display: flex; align-items: center; padding: 0 16px; background: ${panel}; color: ${titleFg};
  font: 13px "JetBrains Mono", monospace; position: relative; }
.dots { display: flex; gap: 8px; }
.dots i { width: 12px; height: 12px; border-radius: 50%; display: block; }
.title { position: absolute; left: 0; right: 0; text-align: center; }
.grid { position: relative; width: ${screen.cols * CW}px; height: ${screen.rows * LH}px;
  font: ${SIZE}px/${LH}px "JetBrains Mono", "Symbols Nerd Font Mono", monospace; font-variant-ligatures: none; }
.c { position: absolute; height: ${LH}px; white-space: pre; overflow: visible; }
.g { font-family: "Symbols Nerd Font Mono", "JetBrains Mono", monospace; text-align: center; }
.cursor { position: absolute; }
</style></head><body>
<div class="window">
  <div class="titlebar"><div class="dots">${dots.map((d) => `<i style="background:${d}"></i>`).join("")}</div><div class="title">${esc(frame.title)}</div></div>
  <div class="grid">${parts.join("")}</div>
</div>
</body></html>`;
}
