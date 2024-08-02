
export enum PlayingFlags {
  NONE = 0,
  TITLE_MUSIC = (1<<0),
}

export class AudioTrack {

  uuid: number;
  url: string;
  priority: number;
  created_at: number;
  volume: number;
  options: {
    pitch?: number,
    start?: number,
    end?: number,
  };
  pos_x: number;
  pos_y: number;
  pos_z: number;
  range: number;
  positional_blend: number;
  playing_flags: PlayingFlags;

  constructor(uuid:number, url: string, priority: number, volume: number, playing_flags: PlayingFlags, options: { pitch?: number, start?: number, end?: number }) {
    // UUID of the track
    this.uuid = uuid;
    // URL of the track
    this.url = url;
    // Priority of the track
    this.priority = priority;
    // The flags of the track
    this.playing_flags = playing_flags;
    // Volume of the track
    this.volume = volume;
    // Time that the track started in milliseconds
    this.created_at = new Date().getTime();
    // Additional options to pass to the track
    this.options = options;
    // X-Coordinate that the track should be playing at.
    this.pos_x = 0;
    // Y-Coordinate that the track should be playing at
    this.pos_y = 0;
    // Z-Coordinate that the track should be playing at
    this.pos_z = 0;
    // Maximum range of this audio-source
    this.range = 10;
    // 3D/2D Blend of the audio. 1 indicates that positional blending should be used.
    // 0 indicates that the sound is abstract and doesn't change volume based on the
    // listener's position.
    // This is kind of weird for numbers in between, but will linearly interpolate
    // between a global sound and a positional sound.
    this.positional_blend = 0;
  }

  /**
   * Update the listener position to re-calculate the volume of this track.
   * @param listener_x The X coordinate of the listener.
   * @param listener_y The Y coordinate of the listener.
   * @param listener_z The Z coordinate of the listener.
   * @returns Returns the new volume of the track
   */
  updateVolume(listener_x: number, listener_y: number, listener_z: number): number {
    // Ignore entirely
    if (this.positional_blend === 0) {
      return this.volume;
    }
    let positionalVolume = 0;
    // If on different Z-levels, ignore entirely
    if (this.pos_z === listener_z) {
      let dx = listener_x - this.pos_x;
      let dy = listener_y - this.pos_y;
      const distance = Math.sqrt(dx * dx + dy * dy);
      positionalVolume = Math.max(0, 1 - (distance / this.range));
    }
    return (positionalVolume * this.positional_blend + (1 - this.positional_blend)) * this.volume;
  }

  /**
   * Calculate the distance between this audio source and the scene's listener.
   * @param listener_x The X coordinate of the listener.
   * @param listener_y The Y coordinate of the listener.
   * @param listener_z The Z coordinate of the listener.
   * @returns The distance, 0 if this is a global sound or infinity if on a different Z-Level.
   */
  calculateDistance(listener_x: number, listener_y: number, listener_z: number): number {
    if (listener_z !== this.pos_z) {
      return Infinity;
    }
    if (this.positional_blend === 0) {
      return 0;
    }
    let dx = listener_x - this.pos_x;
    let dy = listener_y - this.pos_y;
    const distance = Math.sqrt(dx * dx + dy * dy);
    return distance * this.positional_blend;
  }

}
