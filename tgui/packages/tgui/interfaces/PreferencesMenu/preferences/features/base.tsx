import { sortBy } from 'es-toolkit';
import {
  type ComponentType,
  createElement,
  type ReactNode,
  useState,
} from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Slider,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { sendAct } from '../../../../backend';
import { createSetPreference } from '../../data';
import { ServerPreferencesFetcher } from '../../ServerPreferencesFetcher';
import features from '.';

export function sortChoices(array: [string, ReactNode][]) {
  return sortBy(array, [([name]) => name]);
}

export type Feature<
  TReceiving,
  TSending = TReceiving,
  TServerData = unknown,
> = {
  name: string;
  component: FeatureValue<TReceiving, TSending, TServerData>;
  category?: string;
  subcategory?: string;
  description?: string;
  predictable?: boolean;
  small_supplemental?: boolean;
  /** Indicates that a preference is important and likely to be frequently changed by the user. */
  important?: boolean;
};

/**
 * Represents a preference.
 * TReceiving = The type you will be receiving
 * TSending = The type you will be sending
 * TServerData = The data the server sends through preferences.json
 */
type FeatureValue<
  TReceiving,
  TSending = TReceiving,
  TServerData = unknown,
> = ComponentType<FeatureValueProps<TReceiving, TSending, TServerData>>;

export type FeatureValueProps<
  TReceiving,
  TSending = TReceiving,
  TServerData = undefined,
> = Readonly<{
  act: typeof sendAct;
  featureId: string;
  handleSetValue: (newValue: TSending) => void;
  serverData: TServerData | undefined;
  shrink?: boolean;
  value?: TReceiving;
}>;

export function FeatureColorInput(props: FeatureValueProps<string>) {
  return (
    <Button
      tooltip={features[props.featureId].name}
      onClick={() => {
        props.act('set_color_preference', {
          preference: props.featureId,
        });
      }}
    >
      <Stack align="center" fill>
        <Stack.Item>
          <Box
            style={{
              background: props.value?.startsWith('#')
                ? props.value
                : `#${props.value}`,
              border: '2px solid white',
              boxSizing: 'content-box',
              height: '11px',
              width: '11px',
              ...(props.shrink
                ? {
                    margin: '1px',
                  }
                : {}),
            }}
          />
        </Stack.Item>

        {!props.shrink && <Stack.Item>Change</Stack.Item>}
      </Stack>
    </Button>
  );
}

export type FeatureToggle = Feature<BooleanLike, boolean>;

export function TextInput(props: FeatureValueProps<string, string>) {
  const { handleSetValue, value } = props;

  return (
    <Input
      value={value}
      onChange={(e, newValue) => handleSetValue(newValue)}
      width="100%"
    />
  );
}

export function CheckboxInput(props: FeatureValueProps<BooleanLike, boolean>) {
  const { handleSetValue, value } = props;

  return (
    <Button.Checkbox
      checked={!!value}
      onClick={() => {
        handleSetValue(!value);
      }}
    />
  );
}

export function CheckboxInputInverse(
  props: FeatureValueProps<BooleanLike, boolean>,
) {
  const { handleSetValue, value } = props;

  return (
    <Button.Checkbox
      checked={!value}
      onClick={() => {
        handleSetValue(!value);
      }}
    />
  );
}

export function createDropdownInput<T extends string | number = string>(
  // Map of value to display texts
  choices: Record<T, ReactNode>,
  dropdownProps?: Record<T, unknown>,
): FeatureValue<T> {
  return (props: FeatureValueProps<T>) => {
    const { handleSetValue, value } = props;

    return (
      <Dropdown
        selected={choices[value] as string}
        onSelected={handleSetValue}
        width="100%"
        options={sortChoices(Object.entries(choices)).map(
          ([dataValue, label]) => {
            return {
              displayText: label,
              value: dataValue,
            };
          },
        )}
        {...dropdownProps}
      />
    );
  };
}

export type FeatureChoicedServerData = {
  choices: string[];
  display_names?: Record<string, string>;
  icons?: Record<string, string>;
  icon_sheet?: string;
};

export type FeatureChoiced = Feature<string, string, FeatureChoicedServerData>;

export type FeatureNumericData = {
  minimum: number;
  maximum: number;
  step: number;
};

export type FeatureNumeric = Feature<number, number, FeatureNumericData>;

export function FeatureNumberInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { serverData, handleSetValue, value } = props;

  if (!serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <NumberInput
      onChange={(value) => handleSetValue(value)}
      minValue={serverData.minimum}
      maxValue={serverData.maximum}
      step={serverData.step}
      value={value || serverData.minimum}
    />
  );
}

export function FeatureSliderInput(
  props: FeatureValueProps<number, number, FeatureNumericData>,
) {
  const { serverData, handleSetValue, value = 0 } = props;

  if (!serverData) {
    return <Box>Loading...</Box>;
  }

  return (
    <Slider
      onChange={(e, value) => {
        handleSetValue(value);
      }}
      disabled={!serverData}
      minValue={serverData.minimum}
      maxValue={serverData.maximum}
      step={serverData.step}
      value={value}
      stepPixelSize={5}
    />
  );
}

export function FeatureValueInput(props: {
  feature: Feature<unknown>;
  featureId: string;
  shrink?: boolean;
  value: unknown;

  act: typeof sendAct;
}) {
  const feature = props.feature;

  const [predictedValue, setPredictedValue] =
    feature.predictable === undefined || feature.predictable
      ? useState(props.value)
      : [props.value, () => {}];

  function changeValue(newValue: unknown) {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  }

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        return createElement(feature.component, {
          act: props.act,
          featureId: props.featureId,
          serverData: serverData?.[props.featureId] as any,
          shrink: props.shrink,

          handleSetValue: changeValue,
          value: predictedValue,
        });
      }}
    />
  );
}
