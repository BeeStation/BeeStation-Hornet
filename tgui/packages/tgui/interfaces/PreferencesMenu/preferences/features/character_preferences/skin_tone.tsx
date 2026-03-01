import { sortBy } from 'common/collections';
import { useMemo } from 'react';
import { Box, Dropdown, Stack } from 'tgui-core/components';

import { Feature, FeatureChoicedServerData, FeatureValueProps } from '../base';

type SkinToneServerData = FeatureChoicedServerData & {
  display_names: NonNullable<FeatureChoicedServerData['display_names']>;
  to_hex: Record<string, HexValue>;
};

type HexValue = {
  value: string;
  lightness: number;
};

const sortHexValues = (array: [string, HexValue][]) =>
  sortBy(array, ([_, hexValue]) => -hexValue.lightness);

const StandardizedPalette = (props: {
  choices: string[];
  choices_to_hex: Record<string, string>;
  displayNames: Record<string, string>;
  onSetValue: (value: string) => void;
  value: string;
}) => {
  const { choices, choices_to_hex, displayNames, onSetValue, value } = props;

  const options = useMemo(() => {
    return choices.map((choice) => ({
      value: choice,
      displayText: (
        <Stack align="center" fill key={choice}>
          <Stack.Item>
            <Box
              style={{
                background: choices_to_hex[choice],
                boxSizing: 'content-box',
                height: '11px',
                width: '11px',
              }}
            />
          </Stack.Item>

          <Stack.Item grow>{displayNames[choice]}</Stack.Item>
        </Stack>
      ),
    }));
  }, [choices, choices_to_hex, displayNames]);

  return (
    <Dropdown
      buttons
      displayText={
        options.find((option) => option.value === value)?.displayText
      }
      onSelected={(selectedValue) => onSetValue(selectedValue)}
      options={options}
      selected={value}
      width="100%"
    />
  );
};

export const skin_tone: Feature<string, string, SkinToneServerData> = {
  name: 'Skin Tone',
  component: (props: FeatureValueProps<string, string, SkinToneServerData>) => {
    const { handleSetValue, serverData, value } = props;

    if (!serverData) {
      return null;
    }

    const sortedChoices = sortHexValues(Object.entries(serverData.to_hex)).map(
      ([key]) => key,
    );

    return (
      <StandardizedPalette
        choices={sortedChoices}
        choices_to_hex={Object.fromEntries(
          Object.entries(serverData.to_hex).map(([key, hex]) => [
            key,
            hex.value,
          ]),
        )}
        displayNames={serverData.display_names}
        onSetValue={handleSetValue}
        value={value || sortedChoices[0] || ''}
      />
    );
  },
};
