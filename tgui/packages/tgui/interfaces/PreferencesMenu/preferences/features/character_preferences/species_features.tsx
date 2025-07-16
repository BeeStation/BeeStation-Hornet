import { FeatureColorInput, Feature, FeatureChoiced, FeatureValueProps, FeatureButtonedDropdownInput, StandardizedPalette } from '../base';

export const eye_color: Feature<string> = {
  name: 'Eye color',
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: 'Facial hair color',
  component: FeatureColorInput,
};

export const facial_hair_gradient: FeatureChoiced = {
  name: 'Facial hair gradient',
  component: FeatureButtonedDropdownInput,
};

export const facial_hair_gradient_color: Feature<string> = {
  name: 'Facial hair gradient color',
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: 'Hair color',
  component: FeatureColorInput,
};

export const gradient_style: FeatureChoiced = {
  name: 'Hair gradient',
  component: FeatureButtonedDropdownInput,
};

export const gradient_color: Feature<string> = {
  name: 'Hair gradient color',
  component: FeatureColorInput,
};

export const feature_human_ears: FeatureChoiced = {
  name: 'Ears',
  component: FeatureButtonedDropdownInput,
};

export const feature_human_tail: FeatureChoiced = {
  name: 'Tail',
  component: FeatureButtonedDropdownInput,
};

export const feature_monkey_tail: FeatureChoiced = {
  name: 'Tail',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_body_markings: FeatureChoiced = {
  name: 'Body Markings',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_frills: FeatureChoiced = {
  name: 'Frills',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_horns: FeatureChoiced = {
  name: 'Horns',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_legs: FeatureChoiced = {
  name: 'Legs',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_snout: FeatureChoiced = {
  name: 'Snout',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_spines: FeatureChoiced = {
  name: 'Spines',
  component: FeatureButtonedDropdownInput,
};

export const feature_lizard_tail: FeatureChoiced = {
  name: 'Tail',
  component: FeatureButtonedDropdownInput,
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
  component: FeatureButtonedDropdownInput,
};

export const feature_ipc_antenna_color: Feature<string> = {
  name: 'Antenna Color',
  component: FeatureColorInput,
};

export const feature_ipc_screen_color: Feature<string> = {
  name: 'Screen Color',
  component: FeatureColorInput,
};

export const feature_insect_type: FeatureChoiced = {
  name: 'Insect Type',
  component: FeatureButtonedDropdownInput,
};
