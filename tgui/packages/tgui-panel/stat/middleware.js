
import { StatPanel } from './statPanel';
import { sendMessage } from 'tgui/backend';

export const statMiddleware = store => {
  const stat = new StatPanel();

  return next => action => {

    const { type, payload } = action;

    if (type === 'stat/setTab') {
      sendMessage({
        type: 'stat/setTab',
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
