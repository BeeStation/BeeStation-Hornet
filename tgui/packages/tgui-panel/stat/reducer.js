const initialState = {
  selectedTab: 'Status',
  antagonist_popup: null,
  alert_popup: null,
  dead_popup: false,
  statTabs: [],
  statInfomation: [],
  statTabMode: "Scroll",
};

export const statReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'stat/setTab') {
    return {
      ...state,
      selectedTab: payload,
    };
  }
  if (type === 'stat/setStatTabs') {
    return {
      ...state,
      statTabs: payload,
    };
  }
  if (type === 'stat/setPanelInfomation') {
    return {
      ...state,
      statInfomation: payload,
    };
  }
  if (type === 'stat/antagPopup') {
    return {
      ...state,
      antagonist_popup: payload,
    };
  }
  if (type === 'stat/clearAntagPopup') {
    return {
      ...state,
      antagonist_popup: null,
    };
  }
  if (type === 'stat/alertPopup') {
    return {
      ...state,
      alert_popup: payload,
    };
  }
  if (type === 'stat/clearAlertPopup') {
    return {
      ...state,
      alert_popup: null,
    };
  }
  if (type === 'stat/deadPopup') {
    return {
      ...state,
      antagonist_popup: null,
      dead_popup: true,
    };
  }
  if (type === 'stat/clearDeadPopup') {
    return {
      ...state,
      dead_popup: false,
    };
  }
  return state;
};
