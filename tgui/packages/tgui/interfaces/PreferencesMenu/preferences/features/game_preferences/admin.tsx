import { createDropdownInput, Feature, FeatureToggle, CheckboxInput } from '../base';

export const asaycolor: Feature<string> = {
  name: 'Admin chat color',
  category: 'ADMIN',
  subcategory: 'Chat',
  description: 'The color of your messages in Adminsay.',
  component: createDropdownInput(
    {
      cfc_red: 'Red',
      cfc_redorange: 'Redorange',
      cfc_orange: 'Orange',
      cfc_yellow: 'Yellow',
      cfc_lime: 'Lime',
      cfc_green: 'Green',
      cfc_cyan: 'Cyan',
      cfc_bluesky: 'Bluesky',
      cfc_darkbluesky: 'Dark Bluesky',
      cfc_navy: 'Navy',
      cfc_blue: 'Blue',
      cfc_indigo: 'Indigo',
      cfc_purple: 'Purple',
      cfc_violet: 'Violet',
      cfc_magenta: 'Magenta',
      cfc_redpurple: 'Redpurple', // pain. manual addition is innevitable
    },
    {
      buttons: true,
    },
    true // snowflake flag to stop sorting choices alphabetically
  ),
};

export const announce_login: FeatureToggle = {
  name: 'Announce Login',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Whether you will announce whenever you login to fellow admins or not.',
  component: CheckboxInput,
};

export const combohud_lighting: FeatureToggle = {
  name: 'Combo HUD Lighting',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Whether you see combo HUD lighting as fullbright or not.',
  component: CheckboxInput,
};
