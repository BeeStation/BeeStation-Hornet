import { BooleanLike } from 'common/react';
import { sortBy } from 'es-toolkit';
import { Graph, LabeledControls, Section } from 'tgui/components';
import {
  Box, Button, Divider, Flex, Knob, LabeledList, NoticeBox, NumberInput, ProgressBar, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { getGasFromPath } from '../../constants';

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
  core_composition: { [gas_path: string]: number }; // This and the code for sorting it is mostly copied from Supermatter.tsx
  core_moles: number;
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

// <Flex.Item>{core_composition[gas_path].toFixed(2) + ' mol'}</Flex.Item>
// sortBy((material: Material) => rarity[material.name]
const DisplayGasOutput = (core_composition, props) => {
  return core_composition.map(([gas_path, amount]) => (
      <Flex
        key={gas_path}
        justify="space-between"
        p="3px"
        // backgroundColor={getGasFromPath(gas_path)?.color}
        // backgroundColor={index % 2 === 0 ? '#35303b' : '#423f46ff'}
        // backgroundColor={'rgb(136, 136, 136)'}
      >
        <Flex.Item grow={1}>
          {getGasFromPath(gas_path)?.name}
        </Flex.Item>
        <Flex.Item grow={1} textAlign="right" mr={2}>
          {amount.toFixed(2) + ' mol'}
        </Flex.Item>
        <Flex.Item grow={2}>
          <ProgressBar
            minValue={0}
            maxValue={props.core_moles}
            value={amount}
            color={getGasFromPath(gas_path)?.color}
          />
        </Flex.Item>
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
    core_moles,
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

  let gas_composition = Object.entries(props.core_composition);
  gas_composition = sortBy(gas_composition, [([, amount]) => -amount]);

  const sqrt_parabolic_limit = Math.sqrt(parabolic_upper_limit);
  return (
    <Box>
      <Flex direction="row" pb={1}>
        <Flex.Item pr={0.5} grow={1} fill>
          <Section fill>
            <NoticeBox textAlign="center" fontSize={1.5} success={!can_activate}>
                Core Power
            </NoticeBox>
              <Button
                fluid
                textAlign="center"
                icon={'power-off'}
                content={'PWR'}
                selected={!activated}
                disabled={!can_activate}
                onClick={() => act('activate')}
              />
          </Section>
        </Flex.Item>
        <Flex.Item grow={2} pl={0.5} TextAlign="center" fill>
          <Section fill>
            <NoticeBox textAlign="center" fontSize={1.5}>
                Core Health
            </NoticeBox>
          <ProgressBar
            minValue={0}
            maxValue={max_core_health}
            value={core_health}
            ranges={{
              good: [max_core_health * 0.75, Infinity],
              average: [max_core_health * 0.25, max_core_health * 0.75],
              bad: [-Infinity, max_core_health * 0.25],
            }}
          />
          </Section>
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item pr={0.5}>
          <Section title="Controls" width={21.5} fill>
            <Tooltip
              content={
                'Toroid spin is represented by the red bar. Keep it in the middle of the parabola.'
              }
            >
              <Box textAlign="center" pb={1}>
                Parabolic Multiplier
              </Box>
              <Box width="100%" m={0}>
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
            </Tooltip>
            <Divider />
            <LabeledControls pt={1}>
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
        </Flex.Item>
        <Flex.Item grow={1} pl={0.5}>
          <Section title="Data" fill>
              <LabeledList>
                <Tooltip
                  content={
                    'Overhead, how much core instability compares to stability. Keep this above 0%.'
                  }
                >
                  <LabeledList.Item key={'OVRHD'} label={'OVRHD'} color={(core_instability - core_stability) < 0 ? "red" : ""}>
                    {`${core_stability ? FormatLargePercent(((core_instability - core_stability) / core_instability) * 100) : '0'}%`}
                  </LabeledList.Item>
                </Tooltip>
                <Divider />
                <Tooltip content={'Total Instability. Keep this above 0.'} >
                  <LabeledList.Item key={'INSTAB'} label={'INSTAB'} color={(core_instability - core_stability) < 0 ? "red" : ""}>
                    {FormatLargeNum(core_instability - core_stability, 5, 4)}
                  </LabeledList.Item>
                </Tooltip>
                <Divider />
                <Tooltip
                  content={
                    'Spin of the gravimetric toroid. This affects the parabola.'
                  }
                >
                  <LabeledList.Item key={'SPIN'} label={'SPIN'}>
                    {FormatLargeNum(toroid_spin, 5, 4)}
                  </LabeledList.Item>
                </Tooltip>
                <Divider />
                <Tooltip content={'Flux Multiplier. Keep this high.'}>
                  <LabeledList.Item key={'FLXMULT'} label={'FLXMULT'}>
                    {toroid_flux_mult.toFixed(2)}
                  </LabeledList.Item>
                </Tooltip>
                <Divider />
                <Tooltip
                  content={
                    'Core Temperature. Keep this high to increase instability.'
                  }
                >
                  <LabeledList.Item key={'CORETEMP'} label={'CORETEMP'} color={(core_temperature) < 10000 ? "teal" : ""}>
                    {FormatLargeNum(core_temperature, 5, 4)}K
                  </LabeledList.Item>
                </Tooltip>
                <Divider />
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
          </Section>
        </Flex.Item>
      </Flex>
      <Section title="Core Composition" mt={2}>
          {DisplayGasOutput(gas_composition, props)}
      </Section>
    </Box>
  );
};

/*
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
*/
