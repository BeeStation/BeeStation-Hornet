import {
  CheckboxInputInverse,
  Feature,
  FeatureToggle,
} from '../base';
import { FeatureButtonedDropdownInput } from '../dropdowns';

export const hotkeys: FeatureToggle = {
  name: 'Classic hotkeys',
  category: 'GAMEPLAY',
  description:
    'When enabled, will revert to the legacy hotkeys, using the input bar rather than popups.',
  component: CheckboxInputInverse,
};

export const zone_select: Feature<string> = {
  name: 'Bodyzone Targeting Mode',
  category: 'GAMEPLAY',
  description:
    'When set to simplified, the bodyzone system will be replaced with a grouped system where the bodyparts are put into 3 groups: Arms, Legs and Body/Chest. This setting is recommended if you do not have a numpad or want a simpler experience',
  component: FeatureButtonedDropdownInput,
  important: true,
};
