import {
  CheckboxInput,
  type Feature,
  FeatureSliderInput,
  FeatureToggle,
} from '../base';

export const sound_adminhelp: FeatureToggle = {
  name: 'Enable adminhelp sounds',
  category: 'ADMIN',
  subcategory: 'Sound',
  component: CheckboxInput,
  important: true,
};

export const sound_ambience_volume: Feature<number> = {
  name: 'Ambience volume',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: `Volume of the various sounds that play depending on what area of the station you are in.`,
  component: FeatureSliderInput,
  important: true,
};

export const sound_announcements: FeatureToggle = {
  name: 'Enable announcement sounds',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'When enabled, hear sounds for command reports, notices, etc.',
  component: CheckboxInput,
  important: true,
};

export const sound_ghostpoll: FeatureToggle = {
  name: 'Enable ghost polling sound',
  category: 'SOUND',
  description:
    'When enabled, hear an alert when being polled for a ghost role.',
  component: CheckboxInput,
};

export const sound_combatmode: FeatureToggle = {
  name: 'Enable combat mode sound',
  category: 'SOUND',
  description: 'When enabled, hear sounds when toggling combat mode.',
  component: CheckboxInput,
};

export const sound_instruments_volume: Feature<number> = {
  name: 'Instruments volume',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Volume of instruments.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_lobby_volume: Feature<number> = {
  name: 'Lobby music volume',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Volume of the title screen music.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_midi_volume: Feature<number> = {
  name: 'Admin music volume',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Volume of admin music.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_prayers: FeatureToggle = {
  name: 'Enable prayer sounds',
  category: 'ADMIN',
  subcategory: 'Sound',
  component: CheckboxInput,
  important: true,
};

export const sound_adminalert: FeatureToggle = {
  name: 'Enable admin alert sounds',
  category: 'ADMIN',
  subcategory: 'Sound',
  description:
    'Enables sound on various admin notifications such as midround and event triggers.',
  component: CheckboxInput,
  important: true,
};

export const sound_ambient_buzz_volume: Feature<number> = {
  name: 'Ambient buzz volume',
  category: 'SOUND',
  subcategory: 'Ambience',
  description:
    'Volume of the low droning sound playing depending on your area.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_weather_volume: Feature<number> = {
  name: 'Weather volume',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: 'Volume of weather.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_soundtrack_volume: Feature<number> = {
  name: 'Soundtrack volume',
  category: 'SOUND',
  subcategory: 'Music',
  description:
    'Volume of soundtracks, like nuclear countdowns or xenomorph invasions.',
  component: FeatureSliderInput,
  important: true,
};

export const sound_ai_vox_volume: Feature<number> = {
  name: 'AI VOX announcements volume',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Volume of vocal AI announcements (also known as "VOX").',
  component: FeatureSliderInput,
  important: true,
};

export const sound_radio_noise: FeatureToggle = {
  name: 'Enable radio noise',
  category: 'SOUND',
  description:
    'When enabled, hear sounds of talking and hearing radio chatter.',
  component: CheckboxInput,
};
