import { FeatureToggle, CheckboxInput } from '../base';

export const glasses_color: FeatureToggle = {
  name: 'Enable glasses tint',
  category: 'GAMEPLAY',
  description: 'Glasses will tint your client color to match their color.',
  component: CheckboxInput,
};
