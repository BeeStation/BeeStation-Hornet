import { CheckboxInput, FeatureToggle } from '../base';

export const job_estimation_name: FeatureToggle = {
  name: 'Show name in job estimation',
  description:
    'Shows character name in the pre-game Job Estimation panel, which keeps roundstart antagonists that restrict your listed job from picking you.',
  component: CheckboxInput,
};
