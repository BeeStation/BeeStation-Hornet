import { FeatureNumberInput, FeatureNumeric } from '../base';

export const bloom_amount: FeatureNumeric = {
  name: 'Bloom Level',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description:
    'What percentage of bloom to show. Bloom is a lighting effect that gives bright lights a whiteout effect. Disabling it entirely may increase client performance, if needed.',
  component: FeatureNumberInput,
};
