import { FeatureColorInput, Feature, FeatureChoiced, FeatureValueProps, FeatureDropdownInput, StandardizedPalette } from '../base';

const eyePresets = {
  // these need to be short color (3 byte) compatible
  '#aaccff': 'Baby Blue',
  '#0099bb': 'Blue-Green',
  '#337788': 'Teal Blue',
  '#005577': 'Dark Cerulean Blue',
  '#889988': 'Artichoke Green',
  '#447766': 'Green-Blue',
  '#117744': 'Teal Green',
  '#336611': 'Forest Green',
  '#aaaa66': 'Hazel',
  '#554411': 'Brown-Green',
  '#664433': 'Brown',
  '#663300': 'Rich Brown',
  '#441100': 'Deep Brown',
  '#884400': 'Amber',
  '#667788': 'Gray',
  '#445566': 'Deep Gray',
  '#990099': 'Alexandria Purple',
  '#eeeeee': 'Albino White',
  '#ccaaaa': 'Albino Pink',
  '#bbddee': 'Albino Blue',
};

export const eye_color: Feature<string> = {
  name: 'Eye Color',
  predictable: false,
  component: (props: FeatureValueProps<string>) => {
    const { handleSetValue, value, featureId, act } = props;

    return (
      <StandardizedPalette
        choices={Object.keys(eyePresets)}
        displayNames={eyePresets}
        onSetValue={handleSetValue}
        value={value}
        hex_values
        allow_custom
        featureId={featureId}
        act={act}
      />
    );
  },
};

export const facial_hair_color: Feature<string> = {
  name: 'Facial Hair Color',
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: 'Hair Color',
  component: FeatureColorInput,
};

export const gradient_color: Feature<string> = {
  name: 'Gradient Color',
  component: FeatureColorInput,
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Leg Type',
  component: FeatureDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: 'Mutant Color',
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Underwear Color',
  component: FeatureColorInput,
};

export const helmet_style: FeatureChoiced = {
  name: 'Helmet Style',
  component: FeatureDropdownInput,
};
