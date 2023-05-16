import { CheckboxInput, FeatureToggle } from '../base';

export const arrivals_rattle: FeatureToggle = {
  name: 'Notify for new arrivals',
  category: 'GHOST',
  description: 'When enabled, you will be notified as a ghost for new crew.',
  component: CheckboxInput,
};

export const death_rattle: FeatureToggle = {
  name: 'Notify for deaths',
  category: 'GHOST',
  description: 'When enabled, you will be notified as a ghost whenever someone dies.',
  component: CheckboxInput,
};
