import {
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureValueProps,
} from '../base';
import { FeatureIconnedDropdownInput } from '../dropdowns';

export const preferred_ai_core_display: FeatureChoiced = {
  name: 'AI Core Display',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    return <FeatureIconnedDropdownInput {...props} />;
  },
};
