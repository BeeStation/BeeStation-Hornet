import { CheckboxInput, FeatureToggle } from '../base';

export const show_credits: FeatureToggle = {
  name: 'Show Credits',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Enables scrolling credit screen at roundend.',
  component: CheckboxInput,
};
