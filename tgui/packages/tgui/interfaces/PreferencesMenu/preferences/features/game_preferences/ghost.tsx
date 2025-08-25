import { binaryInsertWith } from 'common/collections';
import { multiline } from 'common/string';
import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Dropdown, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { PreferencesMenuData } from '../../../data';
import {
  CheckboxInput,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureToggle,
  FeatureValueProps,
} from '../base';
import {
  FeatureButtonedDropdownInput,
  FeatureDropdownInput,
} from '../dropdowns';

export const ghost_accs: FeatureChoiced = {
  name: 'Ghost accessories',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: 'Determines what adjustments your ghost will have.',
  component: FeatureButtonedDropdownInput,
  important: true,
};

type GhostForm = {
  displayText: ReactNode;
  value: string;
};

const insertGhostForm = (collection: GhostForm[], value: GhostForm) =>
  binaryInsertWith(collection, value, ({ value }) => value);

const GhostFormInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) => {
  const { data } = useBackend<PreferencesMenuData>();

  const serverData = props.serverData;
  if (!serverData) {
    return <> </>;
  }

  const displayNames = serverData.display_names;
  if (!displayNames) {
    return <Box color="red">No display names for ghost_form!</Box>;
  }

  const displayTexts = {};
  let options: {
    displayText: ReactNode;
    value: string;
  }[] = [];

  for (const [name, displayName] of Object.entries(displayNames)) {
    const displayText = (
      <Stack>
        <Stack.Item>
          <Box
            className={classes([
              `${serverData.icon_sheet}32x32`,
              serverData.icons![name],
            ])}
            style={{ verticalAlign: 'bottom' }}
          />
        </Stack.Item>

        <Stack.Item grow style={{ lineHeight: '32px' }}>
          {displayName}
        </Stack.Item>
      </Stack>
    );

    displayTexts[name] = displayText;

    const optionEntry = {
      displayText,
      value: name,
    };

    // Put the default ghost on top
    if (name === 'ghost') {
      options.unshift(optionEntry);
    } else {
      options = insertGhostForm(options, optionEntry);
    }
  }

  return (
    <Dropdown
      autoScroll={false}
      disabled={!data.content_unlocked}
      selected={props.value}
      placeholder={props.value ? displayTexts[props.value] : null}
      clipSelectedText={false}
      onSelected={props.handleSetValue}
      width="100%"
      options={options}
      buttons
    />
  );
};

export const ghost_form: FeatureChoiced = {
  name: 'Ghost Appearance',
  category: 'BYOND MEMBER',
  description: 'The appearance of your ghost. Requires BYOND membership.',
  component: GhostFormInput,
  important: true,
};

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

export const ghost_others: FeatureChoiced = {
  name: 'Ghosts of others',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: multiline`
    Do you want the ghosts of others to show up as their own setting, as
    their default sprites, or always as the default white ghost?
  `,
  component: FeatureButtonedDropdownInput,
  important: true,
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Ghost inquisitiveness',
  category: 'GHOST',
  subcategory: 'Behavior',
  description: 'Clicking on something as a ghost will examine it.',
  component: CheckboxInput,
};
