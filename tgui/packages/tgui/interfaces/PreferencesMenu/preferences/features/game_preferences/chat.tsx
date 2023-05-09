import { multiline } from 'common/string';
import { FeatureToggle, CheckboxInput } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Enable Income Updates',
  category: 'CHAT',
  description: 'Receive notifications for your bank account.',
  component: CheckboxInput,
};

export const chat_dead: FeatureToggle = {
  name: 'Enable Deadchat',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Hear All Messages',
  category: 'GHOST',
  description: multiline`
    When enabled, you will be able to hear all speech as a ghost.
    When disabled, you will only be able to hear nearby speech.
  `,
  component: CheckboxInput,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Enable Law Change Updates',
  category: 'GHOST',
  description: 'When enabled, be notified of any new law changes as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'Enable PDA Messages',
  category: 'GHOST',
  description: 'When enabled, be notified of any PDA messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Enable Radio',
  category: 'GHOST',
  description: 'When enabled, be notified of any radio messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'See All Emotes',
  category: 'GHOST',
  description: 'When enabled, see all emotes as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'See All Whispers',
  category: 'GHOST',
  description: multiline`
    When enabled, you will be able to hear all whispers as a ghost.
    When disabled, you will only be able to hear nearby whispers.
  `,
  component: CheckboxInput,
};

export const chat_login_logout: FeatureToggle = {
  name: 'See Login/Logout Messages',
  category: 'GHOST',
  description: 'When enabled, be notified when a player logs in or out.',
  component: CheckboxInput,
};

export const chat_ooc: FeatureToggle = {
  name: 'Enable OOC',
  category: 'CHAT',
  component: CheckboxInput,
};

export const chat_prayer: FeatureToggle = {
  name: 'Listen to prayers',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Enable Pull Request Notifications',
  category: 'CHAT',
  description: 'Be notified when a pull request is made, closed, or merged.',
  component: CheckboxInput,
};
