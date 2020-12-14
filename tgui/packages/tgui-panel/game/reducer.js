/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { connectionLost } from './actions';
import { connectionRestored } from './actions';
import { reconnected } from './actions';

const initialState = {
  // TODO: This is where round info should be.
  roundId: null,
  roundTime: null,
  roundRestartedAt: null,
  connectionLostAt: null,
  rebooting: false,
  reconnectTimer: 0,
  reconnected: false,
};

export const gameReducer = (state = initialState, action) => {
  const { type, payload, meta } = action;
  if (type === 'roundrestart') {
    return {
      ...state,
      roundRestartedAt: meta.now,
      rebooting: true,
      reconnectTimer: 14,
      reconnected: false,
      tryingtoreconnect: true,
    };
  }
  if (type === 'reconnected') {
    return {
      ...state,
      reconnected: true,
      rebooting: false,
    };
  }
  if (state.rebooting === true && state.tryingtoreconnect === true) {
    setInterval(() => { reconnectplease(); }, 10000);
    state.tryingtoreconnect = false;
  }
  if (type === connectionLost.type) {
    return {
      ...state,
      connectionLostAt: meta.now,
    };
  }
  if (type === connectionRestored.type) {
    return {
      ...state,
      connectionLostAt: null,
    };
  }
  let reconnectplease = function () {
    if (state.reconnected === false) {
      Byond.command('.reconnect');
    }
  };
  return state;
};
