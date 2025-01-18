import { CheckboxInput, FeatureToggle, FeatureColorInput, Feature } from '../base';

export const itemoutline_pref: FeatureToggle = {
  name: 'Item outlines',
  category: 'UI',
  subcategory: 'HUD',
  description: 'When enabled, hovering over items will outline them.',
  component: CheckboxInput,
};

export const outline_color: Feature<string> = {
  name: 'Item outline color',
  category: 'UI',
  subcategory: 'HUD',
  description: 'The color of that hovered items will outline with.',
  component: FeatureColorInput,
  important: true,
};
