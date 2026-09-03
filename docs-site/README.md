# Docs Site — Garage Brain

> Browsable UI for `../docs/` (SRS, HLD, LLD, Tech Stack, Project Structure, Feature Matrix, Diagrams, Decisions, Docs UI Plan).
>
> **Hybrid:** Docsify (zero-build, `index.html`) + VitePress (build to static `dist/`). Both read the same `../docs/*.md`.

## Run

### Option A — Docsify, no Node needed ✅ fastest

`index.html` is the site. Docsify fetches `../docs/*.md` at runtime — so **serve from the repo root**, not from `docs-site/` alone.

```bash
# From repo root:
cd garage-brain
python3 -m http.server 3000
# open http://localhost:3000/docs-site/
```

Alternatively, any static server that allows parent-directory reads works (`npx serve .` from repo root).  
If you run `python3 -m http.server` **inside** `docs-site/`, a banner will explain the 404 and tell you to serve from the parent.

### Option B — VitePress, polished

```bash
cd docs-site
npm install
npm run docs:dev     # http://localhost:5173 — hot reload, local search, mermaid
npm run docs:build   # → .vitepress/dist/ (gitignored) — deploy to GitHub Pages / Vercel
npm run docs:preview # preview the built dist
```

VitePress config lives in `.vitepress/config.js` — `srcDir: '../docs'` so no Markdown duplication. Sidebar mirrors `docs/README.md`.

### Option C — Docker / any static host

Copy `docs-site/index.html` + `../docs/` to the same host (e.g., S3/CloudFront) so the relative `../docs/` fetch resolves, or deploy the VitePress `dist/`.

## Deploy

### GitHub Pages (VitePress)

Add `.github/workflows/pages.yml` per `../docs/DOCS_UI_PLAN.md §6`, output `docs-site/.vitepress/dist`.

### Vercel / Netlify

- **Root directory:** `docs-site`
- **Build command:** `npm run docs:build`
- **Output:** `docs-site/.vitepress/dist`  
  — or skip build and set **Publish directory** to `docs-site` to serve Docsify (no build).

## Why two engines?

| Engine | Build | Search | Mermaid | Needs Node? | When to use |
|---|---|---|---|---|---|
| Docsify (`index.html`) | None | `search` plugin | `mermaid.min.js` | No | Fresh machine, `flutter run` only, stakeholder demo |
| VitePress (`.vitepress/`) | `vitepress build` | `local` | plugin | Yes (Node 20+) | Polished deploy, versioned docs |

Both render the same `../docs/*.md`; pick at deploy time.

## Tech choices (all options evaluated)

See `../docs/DOCS_UI_PLAN.md` for the full matrix: **Docsify, VitePress, Docusaurus, Starlight (Astro), MkDocs Material, in-app Flutter (`flutter_markdown`), plain HTML.**

## Adding a page

1. Create `../docs/NEW_PAGE.md`.
2. Update `../docs/README.md` index + `../docs/PROJECT_STRUCTURE.md` tree.
3. Add sidebar entry in `.vitepress/config.js` sidebar and in `docs-site/index.html` virtual sidebar list.
4. Verify: `python3 -m http.server` from repo root still loads the new page; `npm run docs:build` if using VitePress.

## In-app Flutter `/docs` route (optional, not yet wired)

See `../docs/DOCS_UI_PLAN.md §5 — In-app fallback` for the 5-step `flutter_markdown` wiring. When done, `app/lib/routing/app_router.dart` gets a `/docs` `GoRoute`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| Docsify shows 404 for `../docs/README.md` | Serve from repo root (`cd garage-brain && python3 -m http.server`), not from `docs-site/` |
| VitePress `Cannot find module 'vitepress'` | `cd docs-site && npm install` (Node 20+) |
| Mermaid not rendering | VitePress: plugin in `config.js` + `theme/index.js` mermaid init; Docsify: `mermaid.min.js` CDN must load (offline: vendor `public/mermaid.min.js`) |
| Sidebar missing | VitePress: `sidebar` in `.vitepress/config.js`; Docsify: virtual sidebar in `index.html` — add entries in both |
