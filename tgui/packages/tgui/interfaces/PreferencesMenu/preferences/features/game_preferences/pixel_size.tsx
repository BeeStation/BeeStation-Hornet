import { createDropdownInput, Feature } from '../base';

export const pixel_size: Feature<number> = {
  name: 'Pixel Scaling',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'The size of the game and its icons within the map window. Stretch to fit works with all screen sizes, but Pixel Perfect will produce cleaner scaling, if any fit your window.',
  component: createDropdownInput({
    0: 'Stretch to fit',
    1: 'Pixel Perfect 1x',
    1.5: 'Pixel Perfect 1.5x',
    2: 'Pixel Perfect 2x',
    3: 'Pixel Perfect 3x',
    4: 'Pixel Perfect 4x',
    4.5: 'Pixel Perfect 4.5x',
    5: 'Pixel Perfect 5x',
  }),
  important: true,
};
