/**
 * A minimal Neovim UI: runs `nvim --embed`, attaches with `ext_linegrid` and
 * RGB colors, and keeps the composited screen (floats, popup menu and
 * messages included) as a grid of cells, so a screenshot shows exactly what a
 * terminal would.
 */
import { type ChildProcess, spawn } from "node:child_process";
import { decodeMultiStream, encode } from "@msgpack/msgpack";

export interface Attr {
  foreground?: number;
  background?: number;
  special?: number;
  reverse?: boolean;
  italic?: boolean;
  bold?: boolean;
  strikethrough?: boolean;
  underline?: boolean;
  undercurl?: boolean;
  underdouble?: boolean;
  underdotted?: boolean;
  underdashed?: boolean;
}

export interface Cell {
  text: string;
  hl: number;
}

export interface ModeInfo {
  name?: string;
  cursor_shape?: "block" | "horizontal" | "vertical";
  cell_percentage?: number;
  attr_id?: number;
}

export interface Screen {
  rows: number;
  cols: number;
  cells: Cell[][];
  attrs: Map<number, Attr>;
  defaults: { fg: number; bg: number; sp: number };
  cursor: { row: number; col: number };
  mode?: ModeInfo;
}

type Pending = { resolve: (v: unknown) => void; reject: (e: Error) => void };

export class Nvim {
  readonly proc: ChildProcess;
  readonly screen: Screen;
  private nextId = 1;
  private pending = new Map<number, Pending>();
  private modes: ModeInfo[] = [];
  private lastRedraw = Date.now();

  constructor(
    args: string[],
    opts: { cwd: string; env: NodeJS.ProcessEnv; cols: number; rows: number },
  ) {
    this.proc = spawn("nvim", ["--embed", ...args], {
      cwd: opts.cwd,
      env: opts.env,
      stdio: ["pipe", "pipe", "inherit"],
    });
    this.screen = {
      rows: opts.rows,
      cols: opts.cols,
      cells: [],
      attrs: new Map([[0, {}]]),
      defaults: { fg: 0xffffff, bg: 0, sp: 0xff0000 },
      cursor: { row: 0, col: 0 },
    };
    this.resize(opts.cols, opts.rows);
    void this.read();
  }

  private async read() {
    const stdout = this.proc.stdout;
    if (!stdout) throw new Error("nvim has no stdout");
    for await (const msg of decodeMultiStream(stdout)) {
      const m = msg as unknown[];
      if (m[0] === 1) {
        const p = this.pending.get(m[1] as number);
        this.pending.delete(m[1] as number);
        if (m[2]) p?.reject(new Error(JSON.stringify(m[2])));
        else p?.resolve(m[3]);
      } else if (m[0] === 2 && m[1] === "redraw") {
        for (const batch of m[2] as unknown[][]) this.redraw(batch);
        this.lastRedraw = Date.now();
      }
    }
  }

  request<T = unknown>(method: string, ...params: unknown[]): Promise<T> {
    const id = this.nextId++;
    const stdin = this.proc.stdin;
    if (!stdin) throw new Error("nvim has no stdin");
    return new Promise<T>((resolve, reject) => {
      this.pending.set(id, { resolve: resolve as (v: unknown) => void, reject });
      stdin.write(encode([0, id, method, params]));
    });
  }

  attach() {
    const { cols, rows } = this.screen;
    return this.request("nvim_ui_attach", cols, rows, { rgb: true, ext_linegrid: true });
  }

  /** Sends keys as if typed (`<leader>`, `<Esc>` and friends work). */
  input(keys: string) {
    return this.request("nvim_input", keys);
  }

  command(cmd: string) {
    return this.request("nvim_command", cmd);
  }

  lua<T = unknown>(code: string, ...args: unknown[]) {
    return this.request<T>("nvim_exec_lua", code, args);
  }

  /** Resolves once nothing has been redrawn for `quiet` ms (or after `max` ms). */
  async settle(quiet = 400, max = 10_000) {
    const start = Date.now();
    while (Date.now() - start < max) {
      await new Promise((r) => setTimeout(r, 50));
      if (Date.now() - this.lastRedraw >= quiet) return;
    }
  }

  async quit() {
    try {
      await Promise.race([this.command("qa!"), new Promise((r) => setTimeout(r, 1000))]);
    } catch {
      // nvim exits before answering
    }
    this.proc.kill();
  }

  private resize(cols: number, rows: number) {
    this.screen.cols = cols;
    this.screen.rows = rows;
    this.screen.cells = Array.from({ length: rows }, () =>
      Array.from({ length: cols }, () => ({ text: " ", hl: 0 })),
    );
  }

  private redraw([name, ...calls]: unknown[]) {
    const s = this.screen;
    for (const args of calls as unknown[][]) {
      switch (name) {
        case "grid_resize":
          this.resize(args[1] as number, args[2] as number);
          break;
        case "default_colors_set":
          s.defaults = { fg: args[0] as number, bg: args[1] as number, sp: args[2] as number };
          break;
        case "hl_attr_define":
          s.attrs.set(args[0] as number, args[1] as Attr);
          break;
        case "grid_clear":
          for (const row of s.cells)
            for (const cell of row) Object.assign(cell, { text: " ", hl: 0 });
          break;
        case "grid_cursor_goto":
          s.cursor = { row: args[1] as number, col: args[2] as number };
          break;
        case "grid_line": {
          const row = s.cells[args[1] as number];
          if (!row) break;
          let col = args[2] as number;
          let hl = 0;
          for (const cell of args[3] as [string, number?, number?][]) {
            if (cell[1] !== undefined) hl = cell[1];
            for (let i = 0; i < (cell[2] ?? 1); i++) {
              const target = row[col++];
              if (target) Object.assign(target, { text: cell[0], hl });
            }
          }
          break;
        }
        case "grid_scroll": {
          // Rows move up by `rows` (down when negative) within [top, bot) × [left, right).
          const [, top, bot, left, right, rows] = args as number[] as [
            number,
            number,
            number,
            number,
            number,
            number,
          ];
          const copy = (to: number) => {
            const src = s.cells[to + rows];
            const dst = s.cells[to];
            if (!src || !dst) return;
            for (let c = left; c < right; c++) dst[c] = { ...(src[c] as Cell) };
          };
          if (rows > 0) for (let r = top; r < bot - rows; r++) copy(r);
          else for (let r = bot - 1; r >= top - rows; r--) copy(r);
          break;
        }
        case "mode_info_set":
          this.modes = args[1] as ModeInfo[];
          break;
        case "mode_change":
          s.mode = this.modes[args[1] as number];
          break;
      }
    }
  }
}
