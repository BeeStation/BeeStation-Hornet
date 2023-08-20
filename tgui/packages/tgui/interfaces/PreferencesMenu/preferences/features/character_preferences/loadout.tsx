import { CheckboxInput, FeatureToggle } from '../base';

export const always_equip_loadout_items: FeatureToggle = {
  name: 'Always Equip Loadout Items',
  description:
    'Replaces any worn items you start your job with your loadout items, putting the old items in a box in your backpack.',
  component: CheckboxInput,
};
