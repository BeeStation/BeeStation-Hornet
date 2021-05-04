import { setTabs, setStatTabs, setPanelInfomation, antagPopup, clearAntagPopup, alertPopup, clearAlertPopup, deadPopup, clearDeadPopup } from './actions';

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
  if (type === setTabs.type) {
    return {
      ...state,
      selectedTab: payload,
    };
  }
  if (type === setStatTabs.type) {
    return {
      ...state,
      statTabs: payload,
    };
  }
  if (type === setPanelInfomation.type) {
    return {
      ...state,
      statInfomation: payload,
    };
  }
  if (type === antagPopup.type) {
    return {
      ...state,
      antagonist_popup: payload,
    };
  }
  if (type === clearAntagPopup.type) {
    return {
      ...state,
      antagonist_popup: null,
    };
  }
  if (type === alertPopup.type) {
    return {
      ...state,
      alert_popup: payload,
    };
  }
  if (type === clearAlertPopup.type) {
    return {
      ...state,
      alert_popup: null,
    };
  }
  if (type === deadPopup.type) {
    return {
      ...state,
      antagonist_popup: null,
      dead_popup: true,
    };
  }
  if (type === clearDeadPopup.type) {
    return {
      ...state,
      dead_popup: false,
    };
  }
  return state;
};
