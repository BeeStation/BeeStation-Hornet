
const initialState = {
  selectedTab: 'Status',
  infomationInitial: [],
  infomationUpdate: [],
};

export const statReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'stat/setTab'){
    return {
      ...state,
      selectedTab: payload,
    };
  }
  if(type === 'stat/setInfo'){
    return {
      ...state,
      infomationInitial: payload,
    };
  }
  if(type === 'stat/updateInfo'){
    return {
      ...state,
      infomationUpdate: payload,
    };
  }
  return state;
}
