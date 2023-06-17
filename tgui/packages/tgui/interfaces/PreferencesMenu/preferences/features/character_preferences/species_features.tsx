import { FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput } from '../base';

export const eye_color: Feature<string> = {
  name: 'Eye color',
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: 'Facial hair color',
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: 'Hair color',
  component: FeatureColorInput,
};

export const gradient_color: Feature<string> = {
  name: 'Gradient color',
  component: FeatureColorInput,
};

export const feature_mcolor: Feature<string> = {
  name: 'Mutant color',
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: 'Underwear color',
  component: FeatureColorInput,
};

export const helmet_style: FeatureChoiced = {
  name: 'Helmet style',
  component: FeatureDropdownInput,
};
