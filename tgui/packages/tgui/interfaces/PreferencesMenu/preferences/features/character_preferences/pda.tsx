import { Feature, FeatureChoiced, FeatureChoicedServerData, FeatureColorInput, FeatureDropdownInput, FeatureValueProps } from '../base';

export const pda_theme: FeatureChoiced = {
  name: 'PDA Theme',
  component: (props: FeatureValueProps<string, string, FeatureChoicedServerData>) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};

export const pda_classic_color: Feature<string> = {
  name: 'Thinktronic Classic Color',
  component: FeatureColorInput,
};
