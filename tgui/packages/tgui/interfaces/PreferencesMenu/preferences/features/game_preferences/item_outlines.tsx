import { CheckboxInput, FeatureToggle, FeatureColorInput } from '../base';

export const itemoutline_pref: FeatureToggle = {
  name: 'Item outlines',
  category: 'GAMEPLAY',
  description: 'When enabled, hovering over items will outline them.',
  component: CheckboxInput,
};

export const outline_color: Feature<string> = {
  name: 'Item outline color',
  category: 'GAMEPLAY',
  description: 'The color of that hovered items will outline with.',
  component: FeatureColorInput,
};
