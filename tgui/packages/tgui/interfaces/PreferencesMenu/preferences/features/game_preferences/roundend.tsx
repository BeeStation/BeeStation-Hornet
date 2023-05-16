import { FeatureToggle, CheckboxInput } from '../base';

export const show_credits: FeatureToggle = {
  name: 'Show Credits',
  category: 'GAMEPLAY',
  description: 'Enables scrolling credit screen at roundend.',
  component: CheckboxInput,
};
