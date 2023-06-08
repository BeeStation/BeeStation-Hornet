import { CheckboxInput, FeatureToggle } from "../base";

export const tgui_fancy: FeatureToggle = {
  name: "Enable fancy tgui",
  category: "UI",
  description: "Makes tgui windows look better, at the cost of compatibility.",
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: "Lock tgui to main monitor",
  category: "UI",
  description: "Locks tgui windows to your main monitor.",
  component: CheckboxInput,
};

export const tgui_say_show_prefix: FeatureToggle = {
  name: 'Say: Show Prefix',
  category: 'UI',
  description: 'If radio prefixes should remain in the chatbox after being typed.',
  component: CheckboxInput,
};
