import { CheckboxInput, FeatureToggle } from '../base';

export const glasses_color: FeatureToggle = {
  name: 'Enable glasses tint',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description:
    "Glasses will tint your entire screen's color to match their color.",
  component: CheckboxInput,
};
