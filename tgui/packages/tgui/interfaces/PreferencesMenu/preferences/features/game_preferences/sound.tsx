import { CheckboxInput, FeatureToggle } from '../base';

export const sound_adminhelp: FeatureToggle = {
  name: 'Enable adminhelp sounds',
  category: 'ADMIN',
  subcategory: 'Sound',
  component: CheckboxInput,
  important: true,
};

export const sound_ambience: FeatureToggle = {
  name: 'Enable ambience',
  category: 'SOUND',
  subcategory: 'Ambience',
  description:
    'When enabled, plays various sounds depending on the area of the station you are in.',
  component: CheckboxInput,
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

export const sound_instruments: FeatureToggle = {
  name: 'Enable instruments',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'When enabled, be able hear instruments in game.',
  component: CheckboxInput,
  important: true,
};

export const sound_lobby: FeatureToggle = {
  name: 'Enable lobby music',
  category: 'SOUND',
  subcategory: 'Music',
  component: CheckboxInput,
  important: true,
};

export const sound_midi: FeatureToggle = {
  name: 'Enable admin music',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'When enabled, admins will be able to play music to you.',
  component: CheckboxInput,
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

export const sound_ship_ambience: FeatureToggle = {
  name: 'Enable ship ambience',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: "Plays a soft droning sound, like that of a ship's engine.",
  component: CheckboxInput,
  important: true,
};

export const sound_soundtrack: FeatureToggle = {
  name: 'Enable soundtrack music',
  category: 'SOUND',
  subcategory: 'Music',
  description:
    'When enabled, hear automatic soundtrack music triggered during situations like nuclear countdowns or xenomorph invasions.',
  component: CheckboxInput,
  important: true,
};

export const sound_vox: FeatureToggle = {
  name: 'Enable AI VOX announcements',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'When enabled, hear AI VOX (text-to-speech) announcements.',
  component: CheckboxInput,
  important: true,
};
