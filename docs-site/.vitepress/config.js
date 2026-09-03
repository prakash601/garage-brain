import { defineConfig } from 'vitepress';

export default defineConfig({
  title: 'Garage Brain — Workshop OS',
  description: 'Offline-first workshop OS — SRS, HLD, LLD, Diagrams',
  base: '/',
  srcDir: '../docs',
  outDir: './.vitepress/dist',
  cleanUrls: true,

  themeConfig: {
    nav: [
      { text: 'Docs', link: '/' },
      { text: 'SRS', link: '/SRS' },
      { text: 'HLD', link: '/HLD' },
      { text: 'LLD', link: '/LLD' },
      { text: 'App', link: 'https://github.com/anomalyco/opencode' },
    ],
    sidebar: [
      { text: 'Overview', items: [
        { text: 'Index', link: '/' },
        { text: 'Decisions', link: '/DECISIONS' },
        { text: 'Feature Matrix', link: '/FEATURE_MATRIX' },
      ]},
      { text: 'Specs', items: [
        { text: 'SRS', link: '/SRS' },
        { text: 'HLD', link: '/HLD' },
        { text: 'LLD', link: '/LLD' },
        { text: 'Tech Stack', link: '/TECH_STACK' },
      ]},
      { text: 'Structure', items: [
        { text: 'Project Structure', link: '/PROJECT_STRUCTURE' },
        { text: 'Diagrams', link: '/DIAGRAMS' },
        { text: 'Docs UI Plan', link: '/DOCS_UI_PLAN' },
      ]},
    ],
    search: { provider: 'local' },
    socialLinks: [{ icon: 'github', link: 'https://github.com/' }],
    footer: { message: 'Free-tier, offline-first, zero vendor notification.' },
  },

  markdown: {
    config(md) {
      const fence = md.renderer.rules.fence;
      md.renderer.rules.fence = function (tokens, idx, options, env, slf) {
        const token = tokens[idx];
        if (token.info.trim() === 'mermaid') {
          return `<pre class="mermaid">${md.utils.escapeHtml(token.content)}</pre>`;
        }
        return fence(tokens, idx, options, env, slf);
      };
    },
  },

  head: [
    ['script', { src: 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js' }],
  ],
});
