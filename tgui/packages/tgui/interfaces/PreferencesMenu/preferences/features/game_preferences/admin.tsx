import { FeatureColorInput, Feature, FeatureToggle, CheckboxInput } from '../base';

export const asaycolor: Feature<string> = {
  name: 'Admin chat color',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'The color of your messages in Adminsay.',
  component: FeatureColorInput,
};

export const announce_login: FeatureToggle = {
  name: 'Announce Login',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Whether you will announce whenever you login to fellow admins or not.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Combo HUD Lighting',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Whether you see combo HUD lighting as fullbright or not.',
  component: CheckboxInput,
};
