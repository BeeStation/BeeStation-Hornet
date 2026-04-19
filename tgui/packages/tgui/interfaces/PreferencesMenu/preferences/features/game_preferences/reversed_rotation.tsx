import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const reversed_rotation: FeatureToggle = {
  name: 'Reverse Object Rotation Direction',
  category: 'GAMEPLAY',
  description: multiline`
    When toggled, objects will rotate in the opposite direction.
  `,
  component: CheckboxInput,
  important: true,
};
