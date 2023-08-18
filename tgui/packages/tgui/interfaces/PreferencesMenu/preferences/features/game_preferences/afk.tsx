import { FeatureNumberInput, FeatureNumeric } from '../base';

export const afk_time: FeatureNumeric = {
  name: 'Time until AFK (in minutes)',
  category: 'GAMEPLAY',
  description: 'How long you can be inactive for before you are shown as SSD when examined.',
  component: FeatureNumberInput,
};
