import { CheckboxInput, FeatureToggle } from '../base';

export const fullscreen: FeatureToggle = {
  name: 'Fullscreen Mode',
  category: 'GRAPHICS',
  subcategory: 'Quality',
  description:
    'Enabling this will cause the game window to take up the entire screen space, hiding the taskbar.',
  component: CheckboxInput,
  important: true,
};
