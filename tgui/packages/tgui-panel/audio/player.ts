/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';
import { AudioTrack } from './AudioTrack';

const logger = createLogger('AudioPlayer');

export class AudioPlayer {

  node: HTMLAudioElement;
  playing: boolean;
  volume: number;
  options: {
    pitch?: number,
    start?: number,
    end?: number,
  };
  listener: {
    x: number,
    y: number,
    z: number,
  };
  onPlaySubscribers: ((HTMLAudioElement, AudioTrack) => void)[];
  onStopSubscribers: (() => void)[];
  onMuteSubscribers: (() => void)[];
  onUnmuteSubscribers: (() => void)[];
  onQueueEmptySubscribers: (() => void)[];
  currently_playing: AudioTrack|null;
  playing_tracks: AudioTrack[];
  muted: boolean;
  private queueEmpty: boolean;
  private playbackInterval: number;

  constructor() {
    // Doesn't support HTMLAudioElement
    if (Byond.IS_LTE_IE9) {
      return;
    }
    logger.log("starting player");
    // Set up the HTMLAudioElement node
    this.node = document.createElement('audio');
    this.node.style.setProperty('display', 'none');
    document.body.appendChild(this.node);
    // Set up other properties
    this.playing = false;
    this.volume = 1;
    this.options = {};
    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
    this.onMuteSubscribers = [];
    this.onUnmuteSubscribers = [];
    this.onQueueEmptySubscribers = [];
    this.currently_playing = null;
    this.muted = false;
    // Setup the listener's position to be (0, 0, 0)
    this.listener = {
      x: 0,
      y: 0,
      z: 0,
    };
    // List of tracks that are currently being played.
    this.playing_tracks = [];
    // Listen for playback start events
    this.node.addEventListener('canplaythrough', () => {
      logger.log('canplaythrough');
      this.playing = true;
      this.node.playbackRate = this.options.pitch || 1;
      this.node.currentTime = this.options.start || 0;
      this.updateVolume();
      this.node.play();
      for (let subscriber of this.onPlaySubscribers) {
        subscriber(this.node, this.currently_playing);
      }
    });
    // Listen for playback stop events
    this.node.addEventListener('ended', () => {
      logger.log('ended');
      if (this.currently_playing !== null) {
        this.playing_tracks.splice(this.playing_tracks.indexOf(this.currently_playing), 1);
      }
      this.updateQueue();
    });
    // Listen for playback errors
    this.node.addEventListener('error', (e) => {
      if (this.playing) {
        logger.log('playback error', e.error);
        this.stop();
      }
    });
    // Check every second to stop the playback at the right time
    this.playbackInterval = window.setInterval(() => {
      if (!this.playing) {
        return;
      }
      const shouldStop = this.options.end && this.options.end > 0 && this.node.currentTime >= this.options.end;
      if (shouldStop) {
        this.stop();
      }
    }, 1000);
  }

  destroy() {
    if (!this.node) {
      return;
    }
    this.node.pause();
    document.removeChild(this.node);
    clearInterval(this.playbackInterval);
  }

  update_listener(x, y, z) {
    this.listener = {
      x: x,
      y: y,
      z: z,
    };
    // re-scan the queue to resolve any distance based songs
    this.updateQueue();
  }

  /**
   * Adds a new track to be played by the player, updating the currently played
   * track so that the highest priority one is queued.
   * @param track The track to be played
   */
  play(track: AudioTrack) {
    if (!this.node) {
      return;
    }
    logger.log("play");
    this.playing_tracks.push(track);
    this.updateQueue();
  }

  private updateQueue(): void {
    if (this.playing_tracks.length === 0) {
      if (!this.queueEmpty) {
        for (let subscriber of this.onQueueEmptySubscribers) {
          subscriber();
        }
        this.queueEmpty = true;
      }
    } else {
      this.queueEmpty = false;
    }
    // Scan for priority levels
    let highestPriority = -Infinity;
    let bestDistance = Infinity;
    let bestTrack: AudioTrack|null = null;
    for (let track of this.playing_tracks) {
      if (track.priority < highestPriority) {
        continue;
      }
      // Distance only matters for tie-breaks
      const distance = track.calculateDistance(this.listener.x, this.listener.y, this.listener.z);
      if (track.priority === highestPriority && distance > bestDistance) {
        continue;
      }
      if (track.positional_blend >= 1 && distance > track.range) {
        continue;
      }
      highestPriority = track.priority;
      bestDistance = distance;
      bestTrack = track;
    }
    // Stop playing anything as the queue is now empty
    if (bestTrack === null) {
      if (this.playing) {
        this.stop();
      }
      return;
    }
    // If the song that we want is already playing, ignore
    if (bestTrack === this.currently_playing) {
      this.updateVolume();
      return;
    } else if (this.playing) {
      this.stop();
    }
    this.currently_playing = bestTrack;
    // Switch to the new track, play from the correct position
    logger.log('playing', bestTrack.uuid, bestTrack.url, bestTrack.options);
    this.options = {
      pitch: bestTrack.options.pitch,
      start: (bestTrack.options.start ?? 0) + ((new Date().getTime() - bestTrack.created_at) / 1000.0),
      end: bestTrack.options.end,
    };
    this.updateVolume();
    this.node.src = bestTrack.url;
  }

  toggleMute() {
    logger.log("Toggle mute");
    this.muted = !this.muted;
    this.updateVolume();
    if (this.muted) {
      for (let subscriber of this.onMuteSubscribers) {
        subscriber();
      }
    } else {
      for (let subscriber of this.onUnmuteSubscribers) {
        subscriber();
      }
    }
  }

  stop() {
    logger.log("stop");
    if (!this.node) {
      return;
    }
    if (this.playing) {
      for (let subscriber of this.onStopSubscribers) {
        subscriber();
      }
    }
    logger.log('stopping');
    this.currently_playing = null;
    this.playing = false;
    this.node.src = '';
  }

  stopTrack(uuid: number) {
    logger.log("stop track", uuid);
    if (!this.node) {
      return;
    }
    for (let track of this.playing_tracks) {
      if (track.uuid === uuid) {
        this.playing_tracks.splice(this.playing_tracks.indexOf(track), 1);
        break;
      }
    }
    this.updateQueue();
  }

  setSettingVolume(volume) {
    if (!this.node) {
      return;
    }
    logger.log('set volume', volume);
    this.volume = volume;
    this.updateVolume();
  }

  updateVolume() {
    if (this.node === null) {
      return;
    }
    if (this.muted) {
      this.node.volume = 0;
      return;
    }
    if (this.currently_playing !== null) {
      this.node.volume = this.volume * this.currently_playing.updateVolume(this.listener.x, this.listener.y, this.listener.z);
    }
  }

  onPlay(subscriber: (HTMLAudioElement, AudioTrack) => void) {
    if (!this.node) {
      return;
    }
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber) {
    if (!this.node) {
      return;
    }
    this.onStopSubscribers.push(subscriber);
  }

  onMute(subscriber) {
    if (!this.node) {
      return;
    }
    this.onMuteSubscribers.push(subscriber);
  }

  onUnmute(subscriber) {
    if (!this.node) {
      return;
    }
    this.onUnmuteSubscribers.push(subscriber);
  }

  onQueueEmpty(subscriber) {
    if (!this.node) {
      return;
    }
    this.onQueueEmptySubscribers.push(subscriber);
  }

}
