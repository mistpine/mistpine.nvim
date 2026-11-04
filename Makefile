NVIM ?= nvim
PNPM ?= pnpm

.PHONY: test test-plugins sync format lint images

# Unit tests: loading, spec fidelity, contrast, coverage, options.
test:
	$(NVIM) --clean --headless -l tests/run.lua

# Real plugins, cloned into .cache/plugins (or MISTPINE_PLUGINS=dir, read only).
test-plugins:
	$(NVIM) --clean --headless -l tests/plugins/run.lua

# lua/mistpine/palette.lua from the mistpine spec (MISTPINE_DIR, ../mistpine or GitHub).
sync:
	$(NVIM) -l scripts/sync.lua

format:
	stylua .
	$(PNPM) format

lint:
	stylua --check .
	$(PNPM) lint
	$(PNPM) typecheck

# Banner, social preview and screenshots (Node 24+, Chromium; see scripts/render.ts).
images:
	$(PNPM) banner
	$(PNPM) render
