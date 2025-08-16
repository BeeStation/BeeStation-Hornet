import { createDropdownInput, Feature } from '../base';

export const scaling_method: Feature<string> = {
  name: 'Scaling method',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  description:
    'The scaling algorithm used by BYOND to resize game objects. Point sampling looks best, followed by Nearest Neighbor.',
  component: createDropdownInput({
    blur: 'Bilinear',
    distort: 'Nearest Neighbor',
    normal: 'Point Sampling',
  }),
  important: true,
};
