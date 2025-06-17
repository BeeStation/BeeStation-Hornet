import { CheckboxInput, FeatureToggle } from '../base';

export const tgui_fancy: FeatureToggle = {
  name: 'Enable fancy tgui',
  category: 'UI',
  subcategory: 'TGUI',
  description: 'Makes tgui windows look better, at the cost of compatibility.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Lock tgui to main monitor',
  category: 'UI',
  subcategory: 'TGUI',
  description: 'Locks tgui windows to your main monitor.',
  component: CheckboxInput,
};

export const screentips: FeatureToggle = {
  name: 'Enable Screentips',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Enables screentips which give contextual hints about certain items.',
  component: CheckboxInput,
};

export const tgui_say_show_prefix: FeatureToggle = {
  name: 'Keep Radio Prefix',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'If radio prefixes should remain in the chatbox after being typed.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Enable TGUI Input',
  category: 'UI',
  subcategory: 'TGUI Input',
  description: 'Renders input boxes in TGUI. If this is disabled, legacy input boxes will be uesd.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Large Buttons',
  category: 'UI',
  subcategory: 'TGUI Input',
  description: 'Makes TGUI buttons fill the size of the box.',
  component: CheckboxInput,
  important: true,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Swap Submit/Cancel buttons',
  category: 'UI',
  subcategory: 'TGUI Input',
  description: 'Switches the location of the Submit and Cancel buttons. "On" means Submit will be on the left.',
  component: CheckboxInput,
};

export const tgui_say: FeatureToggle = {
  name: 'Enable TGUI Say',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'Renders the Say input in TGUI. If disabled, a legacy input box will be used.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Light Mode',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'Sets TGUI Say to use light mode.',
  component: CheckboxInput,
  important: true,
};

export const tgui_asay: FeatureToggle = {
  name: 'Enable TGUI ASay/MSay/DSay',
  category: 'UI',
  subcategory: 'TGUI Say',
  description: 'Renders the ASay/MSay/DSay input in TGUI. If disabled, a legacy input box will be used.',
  component: CheckboxInput,
};
