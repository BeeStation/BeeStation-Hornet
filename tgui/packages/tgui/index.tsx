/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/abductor.scss';
import './styles/themes/admin.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/clockwork.scss';
import './styles/themes/elevator.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/login.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/narsie.scss';
import './styles/themes/neutral.scss';
import './styles/themes/ntos.scss';
import './styles/themes/wizard.scss';
import './styles/themes-ntos/ntos-colors.scss';
import './styles/themes-ntos/default.scss';
import './styles/themes-ntos/dark.scss';
import './styles/themes-ntos/light.scss';
import './styles/themes-ntos/red.scss';
import './styles/themes-ntos/orange.scss';
import './styles/themes-ntos/yellow.scss';
import './styles/themes-ntos/olive.scss';
import './styles/themes-ntos/green.scss';
import './styles/themes-ntos/teal.scss';
import './styles/themes-ntos/blue.scss';
import './styles/themes-ntos/violet.scss';
import './styles/themes-ntos/purple.scss';
import './styles/themes-ntos/pink.scss';
import './styles/themes-ntos/brown.scss';
import './styles/themes-ntos/grey.scss';
import './styles/themes-ntos/clown-pink.scss';
import './styles/themes-ntos/clown-yellow.scss';
import './styles/themes-ntos/hackerman.scss';
import './styles/themes/generic.scss';
import './styles/themes/generic-yellow.scss';
import './styles/themes/paper.scss';
import './styles/themes/retro.scss';
import './styles/themes/syndicate.scss';
import './styles/themes/thinktronic-classic.scss';

import { configureStore } from './store';

import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { perf } from 'common/perf';
import { setupGlobalEvents } from './events';
import { setupHotKeys } from './hotkeys';
import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';
import { setGlobalStore } from './backend';
import { loadIconRefMap } from './icons';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore();

const renderApp = createRenderer(() => {
  setGlobalStore(store);
  loadIconRefMap();

  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(store);
  return <Component />;
});

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(renderApp);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(['./components', './debug', './layouts', './routes'], () => {
      renderApp();
    });
  }
}

setupApp();
