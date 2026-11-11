import { CheckboxInput, FeatureToggle } from '../base';

export const job_estimation_name: FeatureToggle = {
  name: 'Show name in job estimation',
  category: 'GAMEPLAY',
  description:
    'Toggles whether your name shows in the pre-game Job Estimation panel. \
    Note: Command roles and AI will show with your name regardless of this pref.',
  component: CheckboxInput,
};
