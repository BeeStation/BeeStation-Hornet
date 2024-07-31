/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { AudioTrack } from './AudioTrack';
import { AudioPlayer } from './player';

export const audioMiddleware = (store) => {
  const player = new AudioPlayer();
  player.onPlay(() => {
    store.dispatch({ type: 'audio/playing' });
  });
  player.onStop(() => {
    store.dispatch({ type: 'audio/stopped' });
  });
  player.onMute(() => {
    store.dispatch({ type: 'audio/onMute' });
  });
  player.onUnmute(() => {
    store.dispatch({ type: 'audio/onUnmute' });
  });
  return (next) => (action) => {
    const { type, payload } = action;
    if (type === 'audio/playMusic') {
      const { url, priority, ...options } = payload;
      player.play(new AudioTrack(url, priority, options));
      return next(action);
    }
    if (type === 'audio/playWorldMusic') {
      const { url, priority, x, y, z, range, ...options } = payload;
      let worldTrack = new AudioTrack(url, priority, options);
      worldTrack.pos_x = x;
      worldTrack.pos_y = y;
      worldTrack.pos_z = z;
      worldTrack.positional_blend = 1;
      worldTrack.range = range;
      player.play(worldTrack);
      return next(action);
    }
    if (type === 'audio/updateListener') {
      const { x, y, z } = payload;
      player.update_listener(x, y, z);
      return next(action);
    }
    if (type === 'audio/stopMusic') {
      player.stop();
      return next(action);
    }
    if (type === 'audio/muteMusic') {
      player.toggleMute();
      return next(action);
    }
    if (type === 'settings/update' || type === 'settings/load') {
      const volume = payload?.adminMusicVolume;
      if (typeof volume === 'number') {
        player.setSettingVolume(volume);
      }
      return next(action);
    }
    return next(action);
  };
};
