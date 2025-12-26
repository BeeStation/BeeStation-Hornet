import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const chat_bankcard: FeatureToggle = {
  name: 'Enable Income Updates',
  category: 'CHAT',
  subcategory: 'IC',
  description: 'Receive notifications for your bank account.',
  component: CheckboxInput,
};

export const chat_followghostmindless: FeatureToggle = {
  name: '(F) Mindless',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'When enabled, (F) will be prefixed on mindless mobs in deadchat. When disabled, it will only be shown on mobs with minds.',
  component: CheckboxInput,
};

export const chat_ghostears: FeatureToggle = {
  name: 'Speech',
  category: 'GHOST',
  subcategory: 'Chat',
  description: multiline`
    When enabled, you will be able to hear all speech as a ghost.
    When disabled, you will only be able to hear nearby speech.
  `,
  component: CheckboxInput,
  important: true,
};

export const chat_ghostlaws: FeatureToggle = {
  name: 'Law Changes',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'When enabled, be notified of any new law changes as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostpda: FeatureToggle = {
  name: 'PDA Messages',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'When enabled, be notified of any PDA messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostradio: FeatureToggle = {
  name: 'Radio',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'When enabled, be notified of any radio messages as a ghost.',
  component: CheckboxInput,
};

export const chat_ghostsight: FeatureToggle = {
  name: 'Emotes',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'When enabled, see all emotes as a ghost.',
  component: CheckboxInput,
  important: true,
};

export const chat_ghostwhisper: FeatureToggle = {
  name: 'Whispers',
  category: 'GHOST',
  subcategory: 'Chat',
  description: multiline`
    When enabled, you will be able to hear all whispers as a ghost.
    When disabled, you will only be able to hear nearby whispers.
  `,
  component: CheckboxInput,
  important: true,
};

export const chat_ooc: FeatureToggle = {
  name: 'Enable OOC',
  category: 'CHAT',
  subcategory: 'OOC',
  component: CheckboxInput,
};

export const chat_pullr: FeatureToggle = {
  name: 'Enable Pull Request Notifications',
  category: 'CHAT',
  subcategory: 'OOC',
  description: 'Be notified when a pull request is made, closed, or merged.',
  component: CheckboxInput,
};

// Admin

export const chat_dead: FeatureToggle = {
  name: 'Hear Deadchat',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'Hear all deadchat while adminned.',
  component: CheckboxInput,
  important: true,
};

export const chat_prayer: FeatureToggle = {
  name: 'Hear Prayers',
  category: 'ADMIN',
  subcategory: 'Chat',
  component: CheckboxInput,
  important: true,
};

export const chat_radio: FeatureToggle = {
  name: 'Hear Radio',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'Hear all radio messages while adminned.',
  component: CheckboxInput,
  important: true,
};

export const examine_messages: FeatureToggle = {
  name: 'Enable Examine Messages',
  category: 'CHAT',
  subcategory: 'IC',
  description: "Receive 'player examined x' examine messages in chat.",
  component: CheckboxInput,
};

export const whole_word_examine_links: FeatureToggle = {
  name: 'Whole Word Examine Links',
  category: 'CHAT',
  subcategory: 'IC',
  description: 'Use whole word examine links instead of an appended [?].',
  component: CheckboxInput,
};
