import { CheckboxInput, FeatureToggle } from '../base';

export const auto_fit_viewport: FeatureToggle = {
  name: 'Auto fit viewport',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'Automatically resize the map panel to chat panel ratio to fit the map size, removing black bars from the edges of the view.',
  component: CheckboxInput,
  important: true,
};
