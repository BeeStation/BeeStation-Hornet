import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiSay } from './interfaces/TguiSay';

// Uncomment to enable hot-reloading
// import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';

const renderApp = createRenderer(() => {
  return <TguiSay />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  // Uncomment to enable hot-reloading
  // if (module.hot) {
  //  setupHotReloading();
  // }

  renderApp();
};

setupApp();
