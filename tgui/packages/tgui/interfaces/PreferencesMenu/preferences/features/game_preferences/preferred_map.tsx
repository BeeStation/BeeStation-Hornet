import { multiline } from 'common/string';

import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const preferred_map: FeatureChoiced = {
  name: 'Preferred map',
  category: 'GAMEPLAY',
  description: multiline`
    During map rotation, prefer this map be chosen.
    This does not affect the map vote, only random rotation when a vote
    is not held.
  `,
  component: FeatureButtonedDropdownInput,
};
