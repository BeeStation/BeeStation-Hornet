import { FeatureToggle, CheckboxInput } from '../base';

export const deadmin_always: FeatureToggle = {
  name: 'Always Deadmin',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round.',
  component: CheckboxInput,
};

export const deadmin_antagonist: FeatureToggle = {
  name: 'Deadmin As Antagonist',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as an antagonist.',
  component: CheckboxInput,
};

export const deadmin_position_head: FeatureToggle = {
  name: 'Deadmin As Head of Staff',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as a head of staff.',
  component: CheckboxInput,
};

export const deadmin_position_security: FeatureToggle = {
  name: 'Deadmin As Security',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as security.',
  component: CheckboxInput,
};

export const deadmin_position_silicon: FeatureToggle = {
  name: 'Deadmin As Silicon',
  category: 'ADMIN',
  description: 'Whether you will always deadmin when joining a round as a silicon.',
  component: CheckboxInput,
};
