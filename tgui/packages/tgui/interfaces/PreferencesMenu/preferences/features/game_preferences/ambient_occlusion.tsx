import { CheckboxInput, FeatureToggle } from '../base';

export const ambientocclusion: FeatureToggle = {
  name: 'Enable ambient occlusion',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description: 'Adds soft shadows around the edges of objects.',
  component: CheckboxInput,
};
