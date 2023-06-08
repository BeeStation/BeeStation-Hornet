import { Feature, FeatureColorInput, FeatureDropdownInput } from '../base';

export const pda_color: Feature<string> = {
  name: 'PDA color',
  category: 'GAMEPLAY',
  description: 'The background color of your PDA when using the Thinktronic Classic theme.',
  component: FeatureColorInput,
};

export const pda_theme: Feature<string> = {
  name: 'PDA theme',
  category: 'GAMEPLAY',
  description: 'The theme of your equipped PDA. Changes the NtOS look in Settings.',
  component: FeatureDropdownInput,
};
