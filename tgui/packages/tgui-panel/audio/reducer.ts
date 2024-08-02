/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { AudioTrack } from "./AudioTrack";

const initialState = {
  visible: false,
  playing: false,
  muted: false,
  duration: 0,
  track: null,
};

export const audioReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'audio/playing') {
    return {
      ...state,
      visible: !state.muted,
      playing: true,
      duration: payload.duration,
      track: payload.track,
    };
  }
  if (type === 'audio/stopped') {
    return {
      ...state,
      visible: false,
      playing: false,
    };
  }
  if (type === 'audio/onMute') {
    return {
      ...state,
      muted: true,
      visible: false,
    };
  }
  if (type === 'audio/onUnmute') {
    return {
      ...state,
      muted: false,
    };
  }
  if (type === 'audio/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  return state;
};
