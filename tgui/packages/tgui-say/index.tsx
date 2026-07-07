import './styles/main.scss';

import { createRoot, Root } from 'react-dom/client';

import { TguiSay } from './interfaces/TguiSay';

// Uncomment to enable hot-reloading
// import { setupHotReloading } from 'tgui-dev-server/link/client.mjs';

let reactRoot: Root | null = null;

document.onreadystatechange = function () {
  if (document.readyState !== 'complete') return;

  if (!reactRoot) {
    const root = document.getElementById('react-root');
    reactRoot = createRoot(root!);
  }

  // Uncomment to enable hot-reloading
  // if (import.meta.webpackHot) {
  //  setupHotReloading();
  // }

  reactRoot.render(<TguiSay />);
};
