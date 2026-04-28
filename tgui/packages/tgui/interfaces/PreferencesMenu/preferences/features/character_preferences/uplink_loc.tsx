import { FeatureChoiced } from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const uplink_loc: FeatureChoiced = {
  name: 'Backup Uplink Spawn Location',
  description:
    'The uplink spawn location for antagonists which do not recieve their uplink as a hidden implant, such as blood brothers.',
  component: FeatureButtonedDropdownInput,
};
