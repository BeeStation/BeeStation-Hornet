import { FeatureIconnedDropdownInput, FeatureValueProps, FeatureChoicedServerData, FeatureWithIcons } from '../base';

export const preferred_ai_core_display: FeatureWithIcons<string> = {
  name: 'AI core display',
  component: (
    props: FeatureValueProps<
      {
        value: string;
      },
      string,
      FeatureChoicedServerData
    >
  ) => {
    return <FeatureIconnedDropdownInput buttons {...props} />;
  },
};
