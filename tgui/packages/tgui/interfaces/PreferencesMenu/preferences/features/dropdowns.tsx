import { classes } from 'common/react';
import { capitalizeFirst } from 'common/string';
import { ReactNode } from 'react';
import { Dropdown } from 'tgui-core/components';

import { sendAct } from '../../../../backend';
import { Box, Button, Flex, Stack, Tooltip } from '../../../../components';
import { Feature, FeatureChoicedServerData, FeatureValueProps } from './base';

type DropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
> &
  Partial<{
    disabled: boolean;
    buttons: boolean;
  }>;

type IconnedDropdownInputProps = FeatureValueProps<
  string,
  string,
  FeatureChoicedServerData
>;

export type FeatureWithIcons<T> = Feature<string, T, FeatureChoicedServerData>;

export function FeatureDropdownInput(props: DropdownInputProps) {
  const { serverData, disabled, buttons, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names } = serverData;

  const dropdownOptions = choices.map((choice) => {
    let displayText: ReactNode = display_names
      ? display_names[choice]
      : capitalizeFirst(choice);

    return {
      displayText,
      value: choice,
    };
  });

  let display_text = value || '';
  if (display_names && value) {
    display_text = display_names[value];
  }

  return serverData.choices.length > 5 ? (
    <Dropdown
      buttons={buttons}
      disabled={disabled}
      onSelected={handleSetValue}
      displayText={capitalizeFirst(display_text)}
      options={dropdownOptions}
      selected={value || ''}
      width="100%"
    />
  ) : (
    <StandardizedChoiceButtons
      choices={choices}
      disabled={disabled}
      displayNames={
        display_names ||
        Object.fromEntries(
          serverData.choices.map((choice) => [choice, capitalizeFirst(choice)]),
        )
      }
      onSetValue={handleSetValue}
      value={value}
    />
  );
}

export const FeatureButtonedDropdownInput = (
  props: FeatureValueProps<string, string, FeatureChoicedServerData> & {
    disabled?: boolean;
  },
) => {
  return <FeatureDropdownInput disabled={props.disabled} buttons {...props} />;
};

export function FeatureIconnedDropdownInput(props: IconnedDropdownInputProps) {
  const { serverData, handleSetValue, value } = props;

  if (!serverData) {
    return null;
  }

  const { choices, display_names, icons } = serverData;

  const dropdownOptions = choices.map((choice) => {
    let displayText: ReactNode = display_names
      ? display_names[choice]
      : capitalizeFirst(choice);

    if (icons?.[choice]) {
      displayText = (
        <Stack>
          <Stack.Item>
            <Box
              className={classes(['preferences32x32', icons[choice]])}
              style={{ transform: 'scale(0.8)' }}
            />
          </Stack.Item>
          <Stack.Item grow>{displayText}</Stack.Item>
        </Stack>
      );
    }

    return {
      displayText,
      value: choice,
    };
  });

  let display_text = value || '';
  if (display_names && value) {
    display_text = display_names[value];
  }

  return (
    <Dropdown
      buttons
      displayText={capitalizeFirst(display_text)}
      onSelected={handleSetValue}
      options={dropdownOptions}
      selected={value || ''}
      width="100%"
    />
  );
}

export const StandardizedChoiceButtons = (props: {
  choices: string[];
  disabled?: boolean;
  displayNames: Record<string, ReactNode>;
  onSetValue: (newValue: string) => void;
  value?: string;
}) => {
  const { choices, disabled, displayNames, onSetValue, value } = props;
  return (
    <>
      {choices.map((choice) => (
        <Button
          key={choice}
          content={displayNames[choice]}
          selected={choice === value}
          disabled={disabled}
          onClick={() => onSetValue(choice)}
        />
      ))}
    </>
  );
};

export type HexValue = {
  lightness: number;
  value: string;
};

export const StandardizedPalette = (props: {
  choices: string[];
  choices_to_hex?: Record<string, string>;
  disabled?: boolean;
  displayNames: Record<string, ReactNode>;
  onSetValue: (newValue: string) => void;
  value?: string;
  hex_values?: boolean;
  allow_custom?: boolean;
  act?: typeof sendAct;
  featureId?: string;
  maxWidth?: string;
  backgroundColor?: string;
  includeHex?: boolean;
  height?: number;
}) => {
  const {
    choices,
    disabled,
    displayNames,
    onSetValue,
    hex_values,
    allow_custom,
    maxWidth = '100%',
    backgroundColor,
    includeHex = false,
    height = 16,
  } = props;
  const choices_to_hex = hex_values
    ? Object.fromEntries(choices.map((v) => [v, v]))
    : props.choices_to_hex!;
  const safeHex = (v: string) => {
    if (v.length === 3) {
      // sanitize short colors
      v = v[0] + v[0] + v[1] + v[1] + v[2] + v[2];
    } else if (v.length === 4) {
      v = v[1] + v[1] + v[2] + v[2] + v[3] + v[3];
    }
    return (v.startsWith('#') ? v : `#${v}`).toLowerCase();
  };
  const safeValue = hex_values
    ? props.value && safeHex(props.value)
    : props.value;
  return (
    <Flex
      className="Preferences__standard-palette"
      style={{ alignItems: 'baseline', maxWidth: maxWidth }}
    >
      <Flex.Item
        shrink
        style={{
          borderRadius: '0.16em',
          maxWidth: maxWidth,
          paddingBottom: '-5px',
        }}
        className="section-background"
        backgroundColor={backgroundColor}
        p={0.5}
      >
        <Flex style={{ flexWrap: 'wrap', maxWidth: maxWidth }}>
          {choices.map((choice) => (
            <Flex.Item key={choice} ml={0}>
              <Tooltip
                content={`${displayNames[choice]}${includeHex ? ` (${safeHex(choice)})` : ''}`}
                position="bottom"
              >
                <Box
                  className={classes([
                    'ColorSelectBox',
                    (hex_values ? safeHex(choice) : choice) === safeValue &&
                      'ColorSelectBox--selected',
                    disabled && 'ColorSelectBox--disabled',
                  ])}
                  onClick={
                    disabled
                      ? null
                      : () => onSetValue(hex_values ? safeHex(choice) : choice)
                  }
                  width={height + 'px'}
                  height={height + 'px'}
                >
                  <Box
                    className="ColorSelectBox--inner"
                    style={{
                      backgroundColor: hex_values
                        ? choice
                        : choices_to_hex[choice],
                    }}
                  />
                </Box>
              </Tooltip>
            </Flex.Item>
          ))}
          {allow_custom && (
            <>
              <Flex.Item grow />
              {!Object.values(choices_to_hex)
                .map(safeHex)
                .includes(safeValue!) && (
                <Flex.Item>
                  <Tooltip
                    content={`Your Custom Selection (${safeValue})`}
                    position="bottom"
                  >
                    <Box
                      className={classes([
                        'ColorSelectBox',
                        'ColorSelectBox--selected',
                      ])}
                      width={height + 'px'}
                      height={height + 'px'}
                    >
                      <Box
                        className="ColorSelectBox--inner"
                        style={{
                          backgroundColor: `${safeValue}`,
                        }}
                      />
                    </Box>
                  </Tooltip>
                </Flex.Item>
              )}

              <Flex.Item ml={0.5}>
                <Button
                  tooltip="Choose Custom"
                  tooltipPosition="bottom"
                  height={height + 4 + 'px'}
                  fontSize={height - 4 + 'px'}
                  style={{ borderRadius: '0' }}
                  textAlign="center"
                  icon="plus"
                  color="good"
                  onClick={() => {
                    if (props.act && props.featureId) {
                      props.act('set_color_preference', {
                        preference: props.featureId,
                      });
                    }
                  }}
                />
              </Flex.Item>
            </>
          )}
        </Flex>
      </Flex.Item>
    </Flex>
  );
};
