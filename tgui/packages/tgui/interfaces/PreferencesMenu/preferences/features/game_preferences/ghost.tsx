import { multiline } from 'common/string';
import { CheckboxInput, FeatureChoiced, FeatureChoicedServerData, FeatureDropdownInput, FeatureButtonedDropdownInput, FeatureToggle, FeatureValueProps } from '../base';
import { Box, Dropdown, Flex } from '../../../../../components';
import { classes } from 'common/react';
import type { InfernoNode } from 'inferno';
import { binaryInsertWith } from 'common/collections';
import { useBackend } from '../../../../../backend';
import { PreferencesMenuData } from '../../../data';

export const ghost_accs: FeatureChoiced = {
  name: 'Ghost accessories',
  category: 'GHOST',
  subcategory: 'Appearance',
  description: 'Determines what adjustments your ghost will have.',
  component: FeatureButtonedDropdownInput,
};

const insertGhostForm = binaryInsertWith<{
  displayText: InfernoNode;
  value: string;
}>(({ value }) => value);

const GhostFormInput = (props: FeatureValueProps<string, string, FeatureChoicedServerData>, context) => {
  const { data } = useBackend<PreferencesMenuData>(context);

  const serverData = props.serverData;
  if (!serverData) {
    return;
  }

  const displayNames = serverData.display_names;
  if (!displayNames) {
    return <Box color="red">No display names for ghost_form!</Box>;
  }

  const displayTexts = {};
  let options: {
    displayText: InfernoNode;
    value: string;
  }[] = [];

  for (const [name, displayName] of Object.entries(displayNames)) {
    const displayText = (
      <Flex key={name} style={{ 'overflow-y': 'hidden' }}>
        <Flex.Item>
          <Box className={classes([`preferences32x32`, serverData.icons![name]])} />
        </Flex.Item>

        <Flex.Item grow={1}>{displayName}</Flex.Item>
      </Flex>
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
  component: (props: FeatureValueProps<string, string, FeatureChoicedServerData>, context) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return <FeatureDropdownInput buttons {...props} disabled={!data.content_unlocked} />;
  },
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
};

export const inquisitive_ghost: FeatureToggle = {
  name: 'Ghost inquisitiveness',
  category: 'GHOST',
  subcategory: 'Behavior',
  description: 'Clicking on something as a ghost will examine it.',
  component: CheckboxInput,
};
