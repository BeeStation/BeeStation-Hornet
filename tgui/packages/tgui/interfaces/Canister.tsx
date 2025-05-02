import { toFixed } from 'common/math';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Flex,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
  Tooltip,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

const formatPressure = (value: number) => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

type HoldingTank = {
  name: string;
  tankPressure: number;
};

type Data = {
  portConnected: BooleanLike;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  hasHypernobCrystal: BooleanLike;
  cellCharge: number;
  pressureLimit: number;
  valveOpen: BooleanLike;
  holdingTank: HoldingTank;
  holdingTankLeakPressure: number;
  holdingTankFragPressure: number;
  shielding: BooleanLike;
  reactionSuppressionEnabled: BooleanLike;
};

export const Canister = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    shielding,
    holdingTank,
    pressureLimit,
    valveOpen,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    portConnected,
    cellCharge,
    holdingTankFragPressure,
    holdingTankLeakPressure,
  } = data;

  return (
    <Window width={300} height={270}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item mb={1}>
            <Section
              title="Canister"
              buttons={
                <>
                  <Button
                    icon={shielding ? 'power-off' : 'times'}
                    content={shielding ? 'Shielding-ON' : 'Shielding-OFF'}
                    selected={shielding}
                    onClick={() => act('shielding')}
                  />
                  <Button
                    icon="pencil-alt"
                    content="Relabel"
                    onClick={() => act('relabel')}
                  />
                </>
              }
            >
              <LabeledControls>
                <LabeledControls.Item minWidth="66px" label="Pressure">
                  <AnimatedNumber
                    value={tankPressure}
                    format={(value) => {
                      if (value < 10000) {
                        return toFixed(value) + ' kPa';
                      }
                      return formatSiUnit(value * 1000, 1, 'Pa');
                    }}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item label="Regulator">
                  <Box position="relative" left="-8px">
                    <Knob
                      size={1.25}
                      color={!!valveOpen && 'yellow'}
                      value={releasePressure}
                      unit="kPa"
                      minValue={minReleasePressure}
                      maxValue={maxReleasePressure}
                      step={5}
                      stepPixelSize={1}
                      onDrag={(e, value) =>
                        act('pressure', {
                          pressure: value,
                        })
                      }
                    />
                    <Button
                      fluid
                      position="absolute"
                      top="-2px"
                      right="-20px"
                      color="transparent"
                      icon="fast-forward"
                      onClick={() =>
                        act('pressure', {
                          pressure: maxReleasePressure,
                        })
                      }
                    />
                    <Button
                      fluid
                      position="absolute"
                      top="16px"
                      right="-20px"
                      color="transparent"
                      icon="undo"
                      onClick={() =>
                        act('pressure', {
                          pressure: defaultReleasePressure,
                        })
                      }
                    />
                  </Box>
                </LabeledControls.Item>
                <LabeledControls.Item label="Valve">
                  <Button
                    my={0.5}
                    width="50px"
                    lineHeight={2}
                    fontSize="11px"
                    color={
                      valveOpen ? (holdingTank ? 'caution' : 'danger') : null
                    }
                    content={valveOpen ? 'Open' : 'Closed'}
                    onClick={() => act('valve')}
                  />
                </LabeledControls.Item>
                <LabeledControls.Item mr={1} label="Port">
                  <Tooltip
                    content={portConnected ? 'Connected' : 'Disconnected'}
                    position="top"
                  >
                    <Box position="relative">
                      <Icon
                        size={1.25}
                        name={portConnected ? 'plug' : 'times'}
                        color={portConnected ? 'good' : 'bad'}
                      />
                    </Box>
                  </Tooltip>
                </LabeledControls.Item>
              </LabeledControls>
            </Section>
            <Section>
              <LabeledList>
                <LabeledList.Item label="Cell Charge">
                  {cellCharge > 0 ? cellCharge + '%' : 'Missing Cell'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Section
              height="100%"
              title="Holding Tank"
              buttons={
                !!holdingTank && (
                  <Button
                    icon="eject"
                    color={valveOpen && 'danger'}
                    content="Eject"
                    onClick={() => act('eject')}
                  />
                )
              }
            >
              {!!holdingTank && (
                <LabeledList>
                  <LabeledList.Item label="Label">
                    {holdingTank.name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Pressure">
                    <AnimatedNumber value={holdingTank.tankPressure} /> kPa
                  </LabeledList.Item>
                </LabeledList>
              )}
              {!holdingTank && <Box color="average">No Holding Tank</Box>}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
