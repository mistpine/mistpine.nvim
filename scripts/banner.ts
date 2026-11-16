/**
 * Writes the README banner and the GitHub social preview with
 * @mistpine/port-kit: the mistpine lockup with the `.nvim` suffix in
 * brightGreen (docs/brand.md in mistpine/mistpine).
 *
 *   pnpm banner
 *
 * The colors come from the colorscheme itself (lib/colors.ts). The PNG is
 * drawn by Chromium (CHROMIUM overrides playwright's).
 */
import { join } from "node:path";
import { writeBanners } from "@mistpine/port-kit/banner";
import { loadColors, ROOT } from "./lib/colors.ts";

const { palette, ansi } = loadColors();
await writeBanners(join(ROOT, "assets"), {
  palette,
  ansi,
  suffix: ".nvim",
  accent: "brightGreen",
  label: "mistpine.nvim: the mistpine color scheme for Neovim",
});
console.log("wrote assets/banner.svg, assets/social-preview.svg, assets/social-preview.png");
