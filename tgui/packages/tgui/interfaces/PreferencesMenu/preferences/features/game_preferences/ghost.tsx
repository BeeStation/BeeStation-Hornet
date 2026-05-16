import { multiline } from 'common/string';
import { useBackend } from 'tgui/backend';

import { PreferencesMenuData } from '../../../data';
import {
  CheckboxInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureToggle,
  FeatureValueProps,
} from '../base';
import { FeatureDropdownInput } from '../dropdowns';

export const ghost_hud: FeatureToggle = {
  name: 'Ghost HUD',
  category: 'UI',
  subcategory: 'HUD',
  description: 'Enable HUD buttons for ghosts.',
  component: CheckboxInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: 'Ghost Orbit Shape',
  category: 'BYOND MEMBER',
  description: multiline`
    The shape in which your ghost will orbit.
    Requires BYOND membership.
  `,
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const { data } = useBackend<PreferencesMenuData>();

    return (
      <FeatureDropdownInput
        buttons
        {...props}
        disabled={!data.content_unlocked}
      />
    );
  },
  important: true,
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Ghost inquisitiveness',
  category: 'GHOST',
  subcategory: 'Behavior',
  description: 'Clicking on something as a ghost will examine it.',
  component: CheckboxInput,
};
