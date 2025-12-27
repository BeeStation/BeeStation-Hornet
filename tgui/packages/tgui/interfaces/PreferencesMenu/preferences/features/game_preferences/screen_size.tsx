import { createDropdownInput, Feature } from '../base';

export const screen_size: Feature<string> = {
  name: 'View Size',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'The amount of tiles that you can see, there is no benefit to decreasing the amount of tiles that you can view, and exists to support ultra-thin monitors.',
  component: createDropdownInput({
    '15x15': 'Tiny (15x15)',
    '17x15': 'Small (17x15)',
    '19x15': 'Normal (19x15)',
  }),
  important: true,
};
