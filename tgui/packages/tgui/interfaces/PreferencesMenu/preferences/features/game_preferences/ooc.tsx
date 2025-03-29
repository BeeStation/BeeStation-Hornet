import { CheckboxInput, FeatureColorInput, FeatureToggle, Feature } from '../base';

export const ooccolor: Feature<string> = {
  name: 'OOC Color',
  category: 'CHAT',
  subcategory: 'OOC',
  description: 'The color of your OOC messages.',
  component: FeatureColorInput,
  important: true,
};

export const member_public: FeatureToggle = {
  name: 'Show BYOND Membership',
  category: 'BYOND MEMBER',
  description: 'Whether to show your BYOND membership in OOC or not.',
  component: CheckboxInput,
  important: true,
};
