import { FeatureNumberInput, FeatureNumeric } from '../base';

export const lighting_saturation: FeatureNumeric = {
  name: 'Lighting Saturation',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description:
    'How saturated should the lighting be? Higher values make the lighting pop more, but might look weird.',
  component: FeatureNumberInput,
};
