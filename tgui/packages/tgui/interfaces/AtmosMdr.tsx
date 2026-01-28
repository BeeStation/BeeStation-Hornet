import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Flex,
  Graph,
  Knob,
  LabeledControls,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type CoreComposition = Record<string, number>;

export type MdrData = {
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
  core_health: number;
  max_core_health: number;
  power_output: string;
};

export const AtmosMdr = (props) => {
  const { data } = useBackend<MdrData>();
  return (
    <Window width={550} height={420}>
      <Window.Content scrollable>
        <MdrContent {...data} />
      </Window.Content>
    </Window>
  );
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

export const MdrContent = (props: MdrData) => {
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
    core_health,
    max_core_health,
    power_output,
  } = props;
  const adjusted_parabolic_limit = parabolic_upper_limit * parabolic_setting;
  const sqrt_parabolic_limit = Math.sqrt(adjusted_parabolic_limit);
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
          <LabeledControls.Item minWidth="66px" label="Harvester Connection">
            <Button
              icon={''}
              content={'Reconnect Harvesters'}
              onClick={() => act('reconnect')}
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
                <LabeledList.Item
                  key={'Core Stability'}
                  label={'Core Stability'}
                >
                  {core_stability.toFixed(0)}
                </LabeledList.Item>
                <LabeledList.Item
                  key={'Core Instability'}
                  label={'Core Instability'}
                >
                  {core_instability.toFixed(0)}
                </LabeledList.Item>
                <LabeledList.Item
                  key={'Delta Stability'}
                  label={'Delta Stability'}
                >
                  {(core_stability - core_instability).toFixed(0)}
                </LabeledList.Item>
                <LabeledList.Item key={'Toroid Spin'} label={'Toroid Spin'}>
                  {toroid_spin.toFixed(0)}
                </LabeledList.Item>
                <LabeledList.Item
                  key={'Toroid Flux Mult'}
                  label={'Toroid Flux Mult'}
                >
                  {toroid_flux_mult.toFixed(2)}
                </LabeledList.Item>
                <LabeledList.Item
                  key={'Core Temperature'}
                  label={'Core Temperature'}
                >
                  {core_temperature.toFixed(2)}
                </LabeledList.Item>
                <LabeledList.Item key={'Output Power'} label={'Output Power'}>
                  {power_output}
                </LabeledList.Item>
              </LabeledList>
            </Box>
          </Flex.Item>
          <br />
          <Flex.Item grow={1} m={1} align="center">
            Parabolic Multiplier
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
                    return (
                      -((i - sqrt_parabolic_limit) ** 2) +
                      adjusted_parabolic_limit
                    );
                  }}
                  upperLimit={
                    parabolic_upper_limit + parabolic_upper_limit * 0.03
                  }
                  lowerLimit={0}
                  leftLimit={0}
                  rightLimit={2 * sqrt_parabolic_limit}
                  steps={25}
                  strokeWidth={parabolic_upper_limit * 0.03}
                  fillColor="#ffffff00"
                  lineColor="#ffffff"
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
