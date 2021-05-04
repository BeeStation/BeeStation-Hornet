
import { StatPanel } from './statPanel';
import { setTabs } from './actions';
import { sendMessage } from 'tgui/backend';

export const statMiddleware = store => {
  const stat = new StatPanel();

  return next => action => {

    const { type, payload } = action;

    if (type === setTabs.type) {
      sendMessage({
        type: setTabs.type,
        payload: {
          selectedTab: payload,
        },
      });
      const newTab = payload?.newTab;
      if (typeof newTab === 'string') {
        stat.setTab(newTab);
      }
      return next(action);
    }

    return next(action);
  };
};
