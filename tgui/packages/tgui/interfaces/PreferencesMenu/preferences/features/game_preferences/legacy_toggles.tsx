import { multiline } from 'common/string';
import { FeatureToggle, CheckboxInput } from '../base';

export const admin_ignore_cult_ghost: FeatureToggle = {
  name: 'Prevent being summoned as a cult ghost',
  category: 'ADMIN',
  description: multiline`
    When enabled and observing, prevents Spirit Realm from forcing you
    into a cult ghost.
  `,
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Announce login',
  category: 'ADMIN',
  description: 'Admins will be notified when you login.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Enable fullbright Combo HUD',
  category: 'ADMIN',
  component: CheckboxInput,
};

export const deadmin_always: FeatureToggle = {
  name: 'Auto deadmin - Always',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin.',
  component: CheckboxInput,
};

export const deadmin_antagonist: FeatureToggle = {
  name: 'Auto deadmin - Antagonist',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as an antagonist.',
  component: CheckboxInput,
};

export const deadmin_position_head: FeatureToggle = {
  name: 'Auto deadmin - Head of Staff',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as a head of staff.',
  component: CheckboxInput,
};

export const deadmin_position_security: FeatureToggle = {
  name: 'Auto deadmin - Security',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as a member of security.',
  component: CheckboxInput,
};

export const deadmin_position_silicon: FeatureToggle = {
  name: 'Auto deadmin - Silicon',
  category: 'ADMIN',
  description: 'When enabled, you will automatically deadmin as a silicon.',
  component: CheckboxInput,
};

export const member_public: FeatureToggle = {
  name: 'Publicize BYOND membership',
  category: 'CHAT',
  description: 'When enabled, a BYOND logo will be shown next to your name in OOC.',
  component: CheckboxInput,
};
