import { Feature, FeatureChoiced, FeatureChoicedServerData, FeatureColorInput, FeatureButtonedDropdownInput, FeatureValueProps, FeatureShortTextInput } from '../base';

export const pda_theme: FeatureChoiced = {
  name: 'PDA Theme',
  component: FeatureButtonedDropdownInput,
};

export const pda_classic_color: Feature<string> = {
  name: 'Thinktronic Classic Color',
  component: FeatureColorInput,
};

export const pda_ringtone: Feature<string> = {
  name: 'PDA Ringtone',
  description: "The ringtone you'll hear when someone sends you a PDA message.",
  component: FeatureShortTextInput,
};
