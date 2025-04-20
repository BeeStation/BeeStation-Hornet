import {
  Feature,
  FeatureButtonedDropdownInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureColorInput,
  FeatureValueProps,
} from '../base';

export const pda_theme: FeatureChoiced = {
  name: 'PDA Theme',
  component: FeatureButtonedDropdownInput,
};

export const pda_classic_color: Feature<string> = {
  name: 'Thinktronic Classic Color',
  component: FeatureColorInput,
};
