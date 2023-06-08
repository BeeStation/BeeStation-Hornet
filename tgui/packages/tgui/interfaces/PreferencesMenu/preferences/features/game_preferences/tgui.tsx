import { CheckboxInput, FeatureToggle } from '../base';

export const tgui_fancy: FeatureToggle = {
  name: 'Enable fancy tgui',
  category: 'UI',
  description: 'Makes tgui windows look better, at the cost of compatibility.',
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: 'Lock tgui to main monitor',
  category: 'UI',
  description: 'Locks tgui windows to your main monitor.',
  component: CheckboxInput,
};

export const tgui_say_show_prefix: FeatureToggle = {
  name: 'Say: Show Prefix',
  category: 'UI',
  description: 'If radio prefixes should remain in the chatbox after being typed.',
  component: CheckboxInput,
};

export const tgui_input: FeatureToggle = {
  name: 'Input: Enable TGUI',
  category: 'UI',
  description: 'Renders input boxes in TGUI.',
  component: CheckboxInput,
};

export const tgui_input_large: FeatureToggle = {
  name: 'Input: Larger buttons',
  category: 'UI',
  description: 'Makes TGUI buttons less traditional, more functional.',
  component: CheckboxInput,
};

export const tgui_input_swapped: FeatureToggle = {
  name: 'Input: Swap Submit/Cancel buttons',
  category: 'UI',
  description: 'Switches the location of the Submit and Cancel buttons. On means Submit will be on the left.',
  component: CheckboxInput,
};

export const tgui_say: FeatureToggle = {
  name: 'Say: Enable TGUI',
  category: 'UI',
  description: 'Renders the Say input in TGUI.',
  component: CheckboxInput,
};

export const tgui_say_light_mode: FeatureToggle = {
  name: 'Say: Light mode',
  category: 'UI',
  description: 'Sets TGUI Say to use light mode.',
  component: CheckboxInput,
};
