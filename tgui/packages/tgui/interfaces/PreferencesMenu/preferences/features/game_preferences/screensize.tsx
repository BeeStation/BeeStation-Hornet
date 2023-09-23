import { Feature, FeatureButtonedDropdownInput } from '../base';

export const screensize: Feature<string> = {
  name: 'Screen Size',
  category: 'GRAPHICS',
  subcategory: 'Screen Settings',
  description: 'Set the screen size ratio.',
  component: FeatureButtonedDropdownInput,
};

//      square: '1:1 ratio (15x15)',
//      wide: 'Wide ratio (17x15)',
//      extrawide: 'Extra Wide ratio (19x15)',
