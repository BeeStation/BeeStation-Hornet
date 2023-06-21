import { FeatureChoiced, FeatureChoicedServerData, FeatureDropdownInput, FeatureValueProps } from '../base';

export const preferred_security_department: FeatureChoiced = {
  name: 'Preferred Security Department',
  component: (props: FeatureValueProps<string, string, FeatureChoicedServerData>) => {
    return <FeatureDropdownInput buttons {...props} />;
  },
};
