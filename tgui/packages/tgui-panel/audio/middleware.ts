/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';
import { AudioTrack } from './AudioTrack';
import { AudioPlayer } from './player';

const logger = createLogger('AudioMiddleware');

export const audioMiddleware = (store) => {
  const player = new AudioPlayer();
  player.onPlay((element: HTMLAudioElement, track: AudioTrack) => {
    store.dispatch({
      type: 'audio/playing',
      payload: {
        duration: element.duration,
        track: track,
      },
    });
    // Tell the server about the length of the playing resource
    Byond.sendMessage('music/declareLength', {
      url: track.url,
      length: element.duration,
    });
    logger.log('casting vote', track.url, element.duration);
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
  player.onQueueEmpty(() => {
    Byond.sendMessage('music/queueEmpty');
  });
  return (next) => (action) => {
    const { type, payload } = action;
    if (type === 'audio/playMusic') {
      const { uuid, url, priority, playing_flags, volume, ...options } = payload;
      player.play(new AudioTrack(uuid, url, priority, volume, playing_flags, options));
      return next(action);
    }
    if (type === 'audio/playWorldMusic') {
      const { uuid, url, priority, playing_flags, x, y, z, range, volume, ...options } = payload;
      let worldTrack = new AudioTrack(uuid, url, priority, volume, playing_flags, options);
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
    if (type === 'audio/stopPlaying') {
      const { uuid } = payload;
      player.stopTrack(uuid);
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
    if (type === 'audio/updateVolume') {
      const { uuid, volume } = payload;
      player.setTrackVolume(uuid, volume);
      return next(action);
    }
    if (type === 'audio/updateMusicPosition') {
      const { uuid, x, y, z } = payload;
      player.setTrackPosition(uuid, x, y, z);
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
