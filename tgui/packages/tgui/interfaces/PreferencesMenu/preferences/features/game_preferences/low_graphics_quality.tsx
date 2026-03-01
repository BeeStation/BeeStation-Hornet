import { CheckboxInput, FeatureToggle } from '../base';

export const lowgraphicsquality: FeatureToggle = {
  name: 'Low Graphics Quality',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Significantly reduces visual quality to consume less graphics memory. This feature is only necessary if you are experiencing rendering issues that are not fixed by clearing the cache.',
  component: CheckboxInput,
  important: false,
};
