import { CheckboxInput, FeatureToggle } from '../base';

export const arrivals_rattle: FeatureToggle = {
  name: 'Arrivals',
  category: 'GHOST',
  subcategory: 'Chat',
  description: 'When enabled, you will be notified as a ghost for new crew.',
  component: CheckboxInput,
};

export const death_rattle: FeatureToggle = {
  name: 'Deaths',
  category: 'GHOST',
  subcategory: 'Chat',
  description:
    'When enabled, you will be notified as a ghost whenever someone dies.',
  component: CheckboxInput,
};
