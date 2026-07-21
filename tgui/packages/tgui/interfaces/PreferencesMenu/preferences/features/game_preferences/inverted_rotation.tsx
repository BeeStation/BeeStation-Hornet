import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const inverted_rotation: FeatureToggle = {
  name: 'Invert object rotation by Mouse-click',
  category: 'GAMEPLAY',
  description: multiline`
    By default, LMB rotates counter-clockwise and RMB rotates clockwise. Toggling on this will invert this behavior.
  `,
  component: CheckboxInput,
  important: true,
};
