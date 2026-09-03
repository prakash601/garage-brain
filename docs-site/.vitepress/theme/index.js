import DefaultTheme from 'vitepress/theme';
export default {
  extends: DefaultTheme,
  enhanceApp({}) {
    if (typeof window !== 'undefined') {
      import('mermaid').then(m => {
        m.default.initialize({ startOnLoad: true, theme: 'default', securityLevel: 'loose' });
        m.default.run();
      });
    }
  },
};
