const initialState = {
  selectedTab: 'Status',
  antagonist_popup: null,
  alert_popup: null,
  dead_popup: false,
  alert_br: false,
  statTabs: [],
  statInfomation: [],
  verbData: {},
  statTabMode: 'Scroll',
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
  if (type === 'stat/setVerbInfomation') {
    return {
      ...state,
      verbData: payload,
    };
  }
  if (type === 'stat/removeVerbs') {
    let newVerbData = state.verbData || {};
    Object.keys(payload).forEach((tabName) => {
      payload[tabName].forEach((thing) => {
        if (tabName in newVerbData && thing in newVerbData[tabName]) {
          delete newVerbData[tabName][thing];
          if (Object.keys(newVerbData[tabName]).length === 0) {
            delete newVerbData[tabName];
          }
        }
      });
    });
    return {
      ...state,
      verbData: newVerbData,
    };
  }
  if (type === 'stat/addVerbs') {
    let newVerbData = state.verbData || {};
    for (let tabName in payload) {
      for (let verbName in payload[tabName]) {
        // Find the first key that is greater than the added verb
        let inserted = false;
        let sortedTabDict = {};
        let newTabDict = newVerbData[tabName];
        for (let key in newTabDict) {
          if (key > verbName && !inserted) {
            sortedTabDict[verbName] = payload[tabName][verbName];
            inserted = true;
          }
          sortedTabDict[key] = newTabDict[key];
        }
        if (!inserted) {
          sortedTabDict[verbName] = payload[tabName][verbName];
        }
        // Add the verb
        // newTabDict[verbName] = payload[tabName][verbName];
        // Set the tab dictionary to the editted one
        newVerbData[tabName] = sortedTabDict;
      }
    }
    return {
      ...state,
      verbData: newVerbData,
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
  if (type === 'stat/alertBr') {
    return {
      ...state,
      alert_popup: null,
      alert_br: {
        title: 'Battle Royale',
        text: 'The round end was delayed, would you like to start Battle Royale?',
      },
    };
  }
  if (type === 'stat/clearAlertBr') {
    return {
      ...state,
      alert_br: false,
    };
  }
  return state;
};
