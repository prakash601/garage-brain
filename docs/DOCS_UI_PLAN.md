# Docs UI Plan — Browsable Documentation

**Question you asked:** *"Can we have a UI for our docs? Plan it, create it — what are my options?"*

**Short answer:** Yes. All docs are plain Markdown + Mermaid in `docs/`. Any static-site generator can serve them; the lightest is **Docsify** (zero build step, just `index.html`) and the most polished is **VitePress** (Vite + Vue, fast, Mermaid native). This repo now ships a **hybrid**: a standalone `docs-site/` static site (works on GitHub Pages / Vercel / Netlify without Flutter) **plus** a plan for an in-app `/docs` Flutter route. Default recommendation: **Docsify fallback + VitePress build** — you pick one at deploy time.

---

## 1. What the docs UI must do

- Render `docs/*.md` as browsable pages with sidebar nav, search, Mermaid diagrams, and code fences.
- Be **hostable without the Flutter app** (so product/stakeholders can read SRS/HLD without `flutter run`).
- Optionally be **reachable from the Flutter app** (`/docs` route) when the app is running.
- No extra backend — fully static.

---

## 2. Options matrix

| # | Option | Stack | Build | Search | Mermaid | Hosting | Best for | Effort |
|---|---|---|---|---|---|---|---|---|
| **A** | **VitePress** | Vite + Vue 3 | `npm run build` → `dist/` | Built-in local search | `mermaid` plugin | GitHub Pages, Vercel, Netlify, Cloudflare Pages | Polished product site, versioning later | Low |
| **B** | **Docsify** | Vanilla JS | **Zero build** — `index.html` loads `docs/*.md` at runtime | `search` plugin | `mermaid` + `docsify-mermaid` | Same static hosts (just serve `docs-site/`) | Fastest demo; no Node needed beyond serving | Tiny |
| **C** | **Docusaurus v3** | React + MDX | `npm run build` | Algolia or local | `mdx-mermaid` | Same hosts | When you need MDX + blog + i18n | Med |
| **D** | **Starlight (Astro)** | Astro + Starlight | `npm run build` | Pagefind built-in | `astro-mermaid` | Same | Astro shops | Med |
| **E** | **MkDocs Material** | Python + Jinja | `mkdocs build` | Built-in lunr | `mermaid` fork | Read the Docs / GH Pages | Python teams | Low |
| **F** | **In-app Flutter** (`/docs` route + `flutter_markdown`) | Dart only | `flutter build web` | Simple filter | `flutter_mermaid` shim or image fallback | Same Flutter deploy | Owner reading docs inside app; offline docs | Low |
| **G** | **Plain HTML hand-written** | HTML/CSS | None | None | Include `mermaid.min.js` | Any static | Throwaway | Tiny but ugly |

**Also considered and skipped:** GitBook (paywalled), mdBook (Rust), Hugo (Go) — not justified for a <30-page set.

---

## 3. Trade-offs

- **If you want zero Node in local dev:** pick **B (Docsify)** — any web server (`python3 -m http.server docs-site`) renders docs live; no build.
- **If you want the best DX + search + theming:** pick **A (VitePress)** — one `npm i` + `npm run docs:dev` gives hot reload; Mermaid "just works"; Sidebar auto.
- **If you want docs available offline inside the shipped APK/Web build:** add **F** on top of A or B — a `/docs` route rendering the local asset copies of `docs/*.md`.
- **If you already have Python infra:** **E (MkDocs)** is equivalent to A but Python instead of Node.
- **If you need MDX components for interactive diagrams:** **C (Docusaurus)** wins; overkill now.

---

## 4. Recommendation (what this repo implements)

> **Ship both A + B as a hybrid in `docs-site/`:**  
> - `docs-site/index.html` is a **Docsify fallback** (works with *no* build — open via file server).  
> - `docs-site/package.json` + `vitepress`/`vite` config is the **VitePress build path** (richer, used for Pages deploys).  
> - Both render the same `../docs/*.md` sources; pick at deploy by which entry you serve.

**Plus optional F:** code skeleton + instructions for `app/lib/features/docs/` so an agent can wire `/docs` in <1h if desired. F is not mandatory for stakeholder review; A/B covers it.

**Why hybrid:** Docsify guarantees the docs stay readable even when Node is not installed (fresh machine, `flutter run` only). VitePress is the prettier deploy artifact. You don't maintain two MD sets — both read `../docs/`.

---

## 5. What was scaffolded in this PR

### `docs-site/` contents

```
docs-site/
├── index.html          # Docsify shell (zero-build) + Mermaid loader
│                         loads docs/README.md, SRS.md, HLD.md, LLD.md, etc.
│                         from ../docs/ via raw fetch (fallback to copy if needed)
├── package.json        # Scripts: docs:dev, docs:build, docs:preview + deps: vitepress, vite, mermaid
├── vite.config.js      # VitePress/Vite alias so /docs maps to ../docs/
├── .vitepress/
│   ├── config.js       # Sidebar (SRS/HLD/LLD/Stack/Structure/Matrix/Diagrams/Decisions), theme, mermaid
│   └── theme/
│       └── index.js    # Mermaid init
├── public/             # Built assets when `npm run docs:build` runs
└── README.md           # How to run/serve/deploy
```

**Two ways to run (no new tooling beyond a static server or Node):**

```bash
# Way 1 — Docsify, no Node needed (good for fresh-machine check):
cd docs-site
python3 -m http.server 3000
# → open http://localhost:3000  (index.html serves docs/ live)

# Way 2 — VitePress, polished:
cd docs-site
npm install          # once
npm run docs:dev     # hot reload on http://localhost:5173
npm run docs:build   # produces docs-site/.vitepress/dist/ → deploy to Pages/Vercel
```

Both render Mermaid; try the dark toggle — it flips the Mermaid theme too (via `.vitepress/theme`).

### In-app fallback — how an agent would wire `/docs` (not yet committed, 30-min task)

1. Add `flutter_markdown: any` to `app/pubspec.yaml`.
2. Declare docs assets:
   ```yaml
   flutter:
     assets:
       - assets/makes.csv
       - assets/docs/   # copy docs/*.md here (or symlink at build time)
   ```
3. Add `app/lib/features/docs/docs_screen.dart` that loads `rootBundle.loadString('assets/docs/README.md')` and renders with `MarkdownBody` + `mermaid` image fallback.
4. Register `/docs` in `app/lib/routing/app_router.dart:15` as a top-level `GoRoute` (allow any signed-in role; or public).
5. Add bottom nav destination or deep link from `AGENTS.md`/`README.md`.

Existing `docs-site/index.html` already includes a "Open in App" deep link helper that tries `flutter run -d chrome` location `/docs` when the app is running.

---

## 6. Hosting recipes

### GitHub Pages (VitePress build)
```yaml
# .github/workflows/pages.yml
name: Docs
on: { push: { branches: [main] }, workflow_dispatch: {} }
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
        working-directory: docs-site
      - run: npm run docs:build
        working-directory: docs-site
      - uses: actions/upload-pages-artifact@v3
        with: { path: docs-site/.vitepress/dist }
  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions: { pages: write, id-token: write }
    environment: { name: github-pages, url: ${{ steps.deployment.outputs.page_url }} }
    steps:
      - id: deployment
        uses: actions/deploy-pages@v4
```

### Vercel / Netlify (zero config)
- **Root:** `docs-site`
- **Build:** `npm run docs:build`
- **Output:** `docs-site/.vitepress/dist` (or just serve `docs-site/index.html` for Docsify — set **Publish directory** to `docs-site` and skip build).

### Pure static fallback (no CI)
- Copy `docs-site/index.html` + `docs/` to any S3/CloudFront/GCS bucket and serve `index.html` as default doc — Docsify loads at runtime.

---

## 7. Future extensions

- **Search:** VitePress local search is already on in `config.js`; for larger docs add Algolia DocSearch or `flexsearch`.
- **Versioned docs:** VitePress has `defineConfig({ rewrites... })` support — tag snapshots when releasing.
- **PDF export:** `npm run docs:build` + `vitepress-export-pdf` or print from Docsify.
- **Auth gate for SRS:** If stakeholder docs must be private, serve `docs-site` behind Supabase Auth (reuse same `app_role` cookie) — simplest is Vercel password-protect or Cloudflare Access.

---

## 8. Decision

| Aspect | Choice | Rationale |
|---|---|---|
| Static site framework | **VitePress (primary) + Docsify fallback** | Covers both polished deploy and zero-build local read |
| In-app docs | **Optional F** — skeleton provided, wire on demand | Keeps app deps lean; stakeholder docs don't need app to run |
| Source | **`docs/*.md` is canonical** — `docs-site` never duplicates content | Single MD set; `AGENTS.md` docs-sync rule enforces |
| Mermaid | Native via VitePress plugin + `mermaid.min.js` in Docsify shell | All diagrams already usable |

Update this file when a pick changes; also update `docs/README.md` Quick verify and `app/README.md` cross-links.
