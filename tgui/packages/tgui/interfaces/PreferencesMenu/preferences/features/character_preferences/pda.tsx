import { Feature, FeatureColorInput, FeatureDropdownInput, FeatureValueProps } from '../base';

export const pda_theme: Feature<string> = {
  name: 'PDA Theme',
  component: (props: FeatureValueProps<string, string>) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const pda_classic_color: Feature<string> = {
  name: 'Thinktronic Classic Color',
  component: FeatureColorInput,
};
