import { FeatureToggle, CheckboxInput } from '../base';

export const sound_adminhelp: FeatureToggle = {
  name: 'Enable adminhelp sounds',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const sound_ambience: FeatureToggle = {
  name: 'Enable ambience',
  category: 'SOUND',
  component: CheckboxInput,
};

export const sound_announcements: FeatureToggle = {
  name: 'Enable announcement sounds',
  category: 'SOUND',
  description: 'When enabled, hear sounds for command reports, notices, etc.',
  component: CheckboxInput,
};

export const sound_instruments: FeatureToggle = {
  name: 'Enable instruments',
  category: 'SOUND',
  description: 'When enabled, be able hear instruments in game.',
  component: CheckboxInput,
};

export const sound_lobby: FeatureToggle = {
  name: 'Enable lobby music',
  category: 'SOUND',
  component: CheckboxInput,
};

export const sound_midi: FeatureToggle = {
  name: 'Enable admin music',
  category: 'SOUND',
  description: 'When enabled, admins will be able to play music to you.',
  component: CheckboxInput,
};

export const sound_prayers: FeatureToggle = {
  name: 'Enable prayer sound',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const sound_ship_ambience: FeatureToggle = {
  name: 'Enable ship ambience',
  category: 'SOUND',
  component: CheckboxInput,
};

export const sound_soundtrack: FeatureToggle = {
  name: 'Enable soundtrack music',
  category: 'SOUND',
  description:
    'When enabled, hear automatic soundtrack music triggered during situations like nuclear countdowns or xenomorph invasions.',
  component: CheckboxInput,
};
