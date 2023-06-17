import { Feature, FeatureColorInput, FeatureDropdownInput } from '../base';

export const pda_theme: Feature<string> = {
  name: 'PDA Theme',
  component: FeatureDropdownInput,
};

export const pda_classic_color: Feature<string> = {
  name: 'Thinktronic Classic Color',
  component: FeatureColorInput,
};
