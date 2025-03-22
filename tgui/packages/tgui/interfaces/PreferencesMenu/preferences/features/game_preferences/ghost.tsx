import { multiline } from 'common/string';
import { CheckboxInput, FeatureChoiced, FeatureChoicedServerData, FeatureDropdownInput, FeatureButtonedDropdownInput, FeatureToggle, FeatureValueProps } from '../base';
import { Box, Dropdown, Stack } from '../../../../../components';
import { classes } from 'common/react';
import { ReactNode } from 'react';
import { binaryInsertWith } from 'common/collections';
import { useBackend } from '../../../../../backend';
import { PreferencesMenuData } from '../../../data';

export const ghost_accs: FeatureChoiced = {
  name: 'Ghost accessories',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: 'Determines what adjustments your ghost will have.',
  component: FeatureButtonedDropdownInput,
  important: true,
};

const insertGhostForm = binaryInsertWith<{
  displayText: ReactNode;
  value: string;
}>(({ value }) => value);

const GhostFormInput = (props: FeatureValueProps<string, string, FeatureChoicedServerData>) => {
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
            className={classes([`${serverData.icon_sheet}32x32`, serverData.icons![name]])}
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
      disabled={!data.content_unlocked}
      selected={props.value}
      displayText={props.value ? displayTexts[props.value] : null}
      displayTextFirst
      clipSelectedText={false}
      onSelected={props.handleSetValue}
      width="100%"
      displayHeight="32px"
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
  component: (props: FeatureValueProps<string, string, FeatureChoicedServerData>) => {
    const { data } = useBackend<PreferencesMenuData>();

    return <FeatureDropdownInput buttons {...props} disabled={!data.content_unlocked} />;
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
