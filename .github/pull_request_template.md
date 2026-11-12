<!--
Title: a Conventional Commit header, e.g. `fix: link @lsp.type.enumMember to Constant`.
PRs are squash-merged and the title becomes the commit on main: lowercase,
imperative, 72 characters at most (aim for 50).

Keep every heading. Tick a box only for a command you ran on this branch;
otherwise leave it unticked and say why below it.
-->

## What and why

<!-- What changes and the problem it solves. Link the issue: `Closes #123`. -->

## Checks

- [ ] `make test`
- [ ] `make test-plugins` (if a plugin integration changed)
- [ ] `make lint` (stylua, Biome, tsc)
- [ ] `make sync` leaves `lua/mistpine/palette.lua` unchanged

## Colors

- [ ] Every color is a palette key or a spec blend; no new hex values
- [ ] Bold and italic follow the spec (bold functions, italic strings and comments)
- [ ] `palette.lua` is not edited by hand (color changes go to mistpine first)

## Screenshots

<!-- Before and after for any visible change, with the highlight groups.
Delete if nothing visible changed. -->
