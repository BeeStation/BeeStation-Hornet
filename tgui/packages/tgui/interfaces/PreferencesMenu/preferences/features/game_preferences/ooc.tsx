import { CheckboxInput, FeatureColorInput, FeatureToggle, Feature } from '../base';

export const ooccolor: Feature<string> = {
  name: 'OOC color',
  category: 'CHAT',
  description: 'The color of your OOC messages.',
  component: FeatureColorInput,
};

export const member_public: FeatureToggle = {
  name: 'Show BYOND Membership',
  category: 'CHAT',
  description: 'Whether to show your BYOND membership in OOC or not.',
  component: CheckboxInput,
};
