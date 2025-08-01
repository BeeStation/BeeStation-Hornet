/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/light.scss';

import { perf } from 'common/perf';
import { combineReducers } from 'common/redux';
import { setGlobalStore } from 'tgui/backend';
import { setupGlobalEvents } from 'tgui/events';
import { captureExternalLinks } from 'tgui/links';
import { createRenderer } from 'tgui/renderer';
import { configureStore } from 'tgui/store';
import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';

import { audioMiddleware, audioReducer } from './audio';
import { chatMiddleware, chatReducer } from './chat';
import { gameMiddleware, gameReducer } from './game';
import { setupPanelFocusHacks } from './panelFocus';
import { pingMiddleware, pingReducer } from './ping';
import { settingsMiddleware, settingsReducer } from './settings';
import { statMiddleware, statReducer } from './stat';
import { telemetryMiddleware } from './telemetry';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore({
  reducer: combineReducers({
    audio: audioReducer,
    chat: chatReducer,
    game: gameReducer,
    ping: pingReducer,
    settings: settingsReducer,
    stat: statReducer,
  }),
  middleware: {
    pre: [
      chatMiddleware,
      pingMiddleware,
      telemetryMiddleware,
      settingsMiddleware,
      audioMiddleware,
      gameMiddleware,
      statMiddleware,
    ],
  },
});

const renderApp = createRenderer(() => {
  setGlobalStore(store);

  const { Panel } = require('./Panel');
  return <Panel />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents({
    ignoreWindowFocus: true,
  });
  setupPanelFocusHacks();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(renderApp);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Unhide the panel
  Byond.winset('legacy_output_selector', {
    left: 'output_browser',
  });

  based_winset();

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();

    module.hot.accept(
      ['./audio', './chat', './game', './Notifications', './Panel', './ping', './settings', './stat', './telemetry'],
      () => {
        renderApp();
      }
    );
  }
};

const based_winset = async (based_on_what = 'output') => {
  const winget_output = await Byond.winget(based_on_what);
  Byond.winset('browseroutput', {
    'size': winget_output['size'],
  });
};

setupApp();
