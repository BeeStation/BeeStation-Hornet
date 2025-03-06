import { classes } from 'common/react';
import { FeatureChoiced, FeatureChoicedServerData, FeatureValueProps, sortChoices, FeatureToggle, CheckboxInput } from '../base';
import { Box, Dropdown, Stack } from '../../../../../components';

const UIStyleInput = (props: FeatureValueProps<string, string, FeatureChoicedServerData>) => {
  const { serverData, value } = props;
  if (!serverData) {
    return null;
  }

  const { icons } = serverData;

  if (!icons) {
    return <Box color="red">ui_style had no icons!</Box>;
  }

  const choices = Object.fromEntries(
    Object.entries(icons).map(([name, icon]) => {
      return [
        name,
        <Stack key={name}>
          <Stack.Item>
            <Box
              className={classes(['preferences64x32', icon])}
              style={{
                transform: 'scale(0.8)',
              }}
            />
          </Stack.Item>

          <Stack.Item grow style={{ lineHeight: '32px' }}>
            {name}
          </Stack.Item>
        </Stack>,
      ];
    })
  );

  return (
    <Dropdown
      buttons
      selected={value}
      clipSelectedText={false}
      displayText={value ? choices[value] : null}
      displayTextFirst
      onSelected={props.handleSetValue}
      width="100%"
      displayHeight="32px"
      options={sortChoices(Object.entries(choices)).map(([dataValue, label]) => {
        return {
          displayText: label,
          value: dataValue,
        };
      })}
    />
  );
};

export const ui_style: FeatureChoiced = {
  name: 'HUD Style',
  category: 'UI',
  subcategory: 'HUD',
  component: UIStyleInput,
  important: true,
};

export const intent_style: FeatureToggle = {
  name: 'Enable intent hotclick',
  category: 'UI',
  subcategory: 'HUD',
  description:
    'Clicking on intents will directly select if this is on, otherwise clicking them will rotate the selection clockwise.',
  component: CheckboxInput,
};
