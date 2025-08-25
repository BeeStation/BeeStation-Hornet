import {
  CheckboxInput,
  Feature,
  FeatureNumberInput,
  FeatureNumeric,
  FeatureToggle,
} from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const chat_on_map: FeatureToggle = {
  name: 'Enable Runechat',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Chat messages will show above heads.',
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: 'Enable Runechat on objects',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Chat messages will show above objects when they speak.',
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: 'Enable Runechat emotes',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Emotes will show above heads.',
  component: CheckboxInput,
};

export const max_chat_length: FeatureNumeric = {
  name: 'Max runechat length',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'The maximum length a Runechat message will show as.',
  component: FeatureNumberInput,
};

export const show_balloon_alerts: Feature<string> = {
  name: 'Show balloon alerts',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'Show text above items when certain interactions are used.',
  component: FeatureButtonedDropdownInput,
};

export const enable_runechat_looc: FeatureToggle = {
  name: 'Enable Runechat LOOC',
  category: 'CHAT',
  subcategory: 'Runechat',
  description: 'LOOC messages will show above heads.',
  component: CheckboxInput,
};
