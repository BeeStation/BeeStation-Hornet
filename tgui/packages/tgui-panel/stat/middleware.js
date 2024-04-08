import { StatPanel } from './statPanel';

export const statMiddleware = (store) => {
  const stat = new StatPanel();

  return (next) => (action) => {
    const { type, payload } = action;

    if (type === 'stat/setTab') {
      Byond.sendMessage('stat/setTab', { selectedTab: payload });
      const newTab = payload?.newTab;
      if (typeof newTab === 'string') {
        stat.setTab(newTab);
      }
      return next(action);
    }

    return next(action);
  };
};
