import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  Knob,
  LabeledControls,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Graph, Tooltip } from '../../components';

type CoreComposition = Record<string, number>;

export type CdrData = {
  uid: number;
  area: string;
  toroid_spin: number;
  parabolic_setting: number;
  parabolic_upper_limit: number;
  parabolic_ratio: number;
  input_volume: number;
  toroid_flux_mult: number;
  core_temperature: number;
  core_composition: CoreComposition;
  can_activate: BooleanLike;
  activated: BooleanLike;
  metallization_ratio: number;
  core_stability: number;
  core_instability: number;
  base_instability: number;
  core_health: number;
  max_core_health: number;
  power_output: string;
};

const DisplayGasOutput = (core_composition: CoreComposition) => {
  return Object.keys(core_composition).map((name, index) => (
    <Flex
      key={name}
      justify="space-between"
      p="3px"
      backgroundColor={index % 2 === 0 ? '#35303b' : '#423f46ff'}
    >
      <Flex.Item>{name}</Flex.Item>
      <Flex.Item>{core_composition[name].toFixed(2) + ' mol'}</Flex.Item>
    </Flex>
  ));
};

const FormatLargeNum = (
  large_number: number,
  when_to_format: number,
  to_digits: number,
) => {
  return Math.abs(large_number) > 10 ** when_to_format
    ? large_number.toExponential(to_digits)
    : large_number.toFixed(0);
};

const FormatLargePercent = (large_percent: number) => {
  return Math.abs(large_percent) > 300
    ? large_percent > 0
      ? '>300'
      : '<-300'
    : large_percent.toFixed(0);
};

export const CdrContent = (props: CdrData) => {
  const { act } = useBackend();
  const {
    uid,
    area,
    toroid_spin,
    parabolic_setting,
    parabolic_upper_limit,
    parabolic_ratio,
    input_volume,
    toroid_flux_mult,
    core_temperature,
    core_composition,
    can_activate,
    activated,
    metallization_ratio,
    core_stability,
    core_instability,
    base_instability,
    core_health,
    max_core_health,
    power_output,
  } = props;
  const sqrt_parabolic_limit = Math.sqrt(parabolic_upper_limit);
  return (
    <Box>
      <Section title="Controls">
        <LabeledControls>
          <LabeledControls.Item minWidth="66px" label="Activation">
            <Button
              icon={'power-off'}
              content={'Activate'}
              selected={activated}
              disabled={!can_activate}
              onClick={() => act('activate')}
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="66px" label="Metal. Ratio">
            <Knob
              size={1.25}
              color={'yellow'}
              value={metallization_ratio}
              unit=""
              format={(i) => {
                return i.toFixed(1);
              }}
              minValue={0.1}
              maxValue={1}
              step={0.1}
              stepPixelSize={5}
              onDrag={(e, value) =>
                act('change_metal_ratio', {
                  change_metal_ratio: value,
                })
              }
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="66px" label="Parab. Setting">
            <Knob
              size={1.25}
              color={'yellow'}
              value={parabolic_setting}
              unit=""
              format={(i) => {
                return i.toFixed(1);
              }}
              minValue={0.1}
              maxValue={1}
              step={0.1}
              stepPixelSize={5}
              onDrag={(e, value) =>
                act('change_parabolic_setting', {
                  change_parabolic_setting: value,
                })
              }
            />
          </LabeledControls.Item>
          <LabeledControls.Item minWidth="66px" label="Toroid Input">
            <NumberInput
              animated
              value={input_volume}
              width="75px"
              unit="L/s"
              minValue={0}
              maxValue={200}
              step={10}
              onChange={(value) =>
                act('change_input', {
                  change_input: value,
                })
              }
            />
          </LabeledControls.Item>
        </LabeledControls>
      </Section>
      <Section title="Data">
        Core Health:
        <ProgressBar
          minValue={0}
          maxValue={max_core_health}
          value={core_health}
          ranges={{
            good: [0.7, Infinity],
            average: [0.4, 0.7],
            bad: [-Infinity, 0.4],
          }}
        />
        <Flex>
          <Flex.Item grow={1} m={1}>
            <Box>
              <LabeledList>
                <Tooltip
                  content={
                    'Overhead, how much core instability compares to stability. Keep this above 0%.'
                  }
                >
                  <LabeledList.Item key={'OVRHD'} label={'OVRHD'}>
                    {`${core_stability ? FormatLargePercent(((core_instability - core_stability) / core_instability) * 100) : '0'}%`}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content={'Total Instability. Keep this above 0.'}>
                  <LabeledList.Item key={'INSTAB'} label={'INSTAB'}>
                    {FormatLargeNum(core_instability - core_stability, 5, 4)}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip
                  content={
                    'Spin of the gravimetric toroid. This affects the parabola.'
                  }
                >
                  <LabeledList.Item key={'SPIN'} label={'SPIN'}>
                    {FormatLargeNum(toroid_spin, 5, 4)}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip content={'Flux Multiplier. Keep this high.'}>
                  <LabeledList.Item key={'FLXMULT'} label={'FLXMULT'}>
                    {toroid_flux_mult.toFixed(2)}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip
                  content={
                    'Core Temperature. Keep this high to increase instability.'
                  }
                >
                  <LabeledList.Item key={'CORETEMP'} label={'CORETEMP'}>
                    {FormatLargeNum(core_temperature, 5, 4)}
                  </LabeledList.Item>
                </Tooltip>
                <Tooltip
                  content={
                    'Energy Stored. Large quantities will be ejected in a graviton particle.'
                  }
                >
                  <LabeledList.Item key={'STRDENGY'} label={'STRDENGY'}>
                    {power_output}
                  </LabeledList.Item>
                </Tooltip>
              </LabeledList>
            </Box>
          </Flex.Item>
          <br />
          <Flex.Item grow={1} m={1} align="center">
            <Tooltip
              content={
                'Toroid spin is represented by the red bar. Keep it in the middle of the parabola.'
              }
            >
              <Box>Parabolic Multiplier</Box>
            </Tooltip>
            <Box width="100%" m={1}>
              <Box
                width="100%"
                backgroundColor="grey"
                style={{ aspectRatio: '3 / 1' }}
                position="relative"
              >
                <Box>
                  <svg
                    width="100%"
                    height="100%"
                    viewBox={`0 0 ${2 * sqrt_parabolic_limit} ${(2 * sqrt_parabolic_limit) / 3}`}
                    preserveAspectRatio="none"
                    style={{
                      position: 'absolute',
                    }}
                  >
                    <rect
                      x={parabolic_ratio}
                      width={(2 * sqrt_parabolic_limit) / 100}
                      height="100%"
                      y={0}
                      fill="red"
                    />
                  </svg>
                </Box>
                <Graph
                  funct={(i: number) => {
                    return -((i - 2) ** 2) + 4;
                  }}
                  upperLimit={4.1}
                  lowerLimit={0}
                  leftLimit={0}
                  rightLimit={4}
                  steps={25}
                  strokeWidth={0.05}
                  fillColor="#ffffff00"
                  lineColor="#ffffff"
                  modifier={parabolic_setting}
                />
              </Box>
            </Box>
          </Flex.Item>
        </Flex>
        <Collapsible title="Core Composition" overflow="overlay">
          {DisplayGasOutput(core_composition)}
        </Collapsible>
      </Section>
    </Box>
  );
};
