import { useBackend } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Flex,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

export const AtmosGasRig = (props) => {
  return (
    <Window theme="ntos" width={480} height={500}>
      <Window.Content>
        <Section title="Advanced Gas Rig:" fill={1} overflow-y="scroll">
          <AtmosGasRigTemplate props />
        </Section>
      </Window.Content>
    </Window>
  );
};

const DisplayWarning = (message) => {
  if (message !== null) {
    return <NoticeBox color="red">{message}</NoticeBox>;
  }
  return <Box />;
};

const DisplayGasOutput = (production_list) => {
  return production_list
    .filter((_, index) => index % 2 === 0)
    .map((name, produced) => (
      <Flex
        key={name}
        justify="space-between"
        p="3px"
        backgroundColor={produced % 2 === 0 ? '#35303b' : '#423f46ff'}
      >
        <Flex.Item>{name}</Flex.Item>
        <Flex.Item>
          {production_list[produced * 2 + 1].toFixed(2) + ' mol/s'}
        </Flex.Item>
      </Flex>
    ));
};

const DisplayValues = (position, barHeight, data) => {
  const count = 5;
  let items = [];
  for (let i = 0; i <= count; i++) {
    items.push((data.max_depth / count) * i);
  }
  return items.map((item, index) => (
    <>
      <text
        key={item}
        x={position}
        y={barHeight * (index / count) + 12}
        fill="white"
        fontSize="12px"
      >
        {item}
      </text>
      <rect
        x={position - 15}
        width="10"
        height="1"
        y={barHeight * (index / count) + 6}
        fill="grey"
      />
    </>
  ));
};

const DisplayGasBar = (
  position_bar,
  constant,
  max_depth,
  barHeight,
  color,
  text,
) => {
  const barOffset = 6;
  return (
    <Tooltip content={text}>
      <rect
        x={position_bar}
        y={barHeight * (constant[0] / max_depth) + barOffset}
        width="10"
        height={barHeight * ((constant[1] - constant[0]) / max_depth)}
        fill={color}
      />
    </Tooltip>
  );
};

export const AtmosGasRigTemplate = (props) => {
  const { act, data } = useBackend();
  const {
    depth,
    active,
    max_depth,
    max_shield,
    shield_strength,
    max_health,
    health,
    set_depth,
    shield_strength_change,
    gas_power,
    gas_modifier,
    fracking_eff,
    o2_constants,
    n2_constants,
    co2_constants,
    n2o_constants,
    plas_constants,
    plox_constants,
    trit_constants,
    nob_constants,
    bz_constants,
    mols_produced = [],
  } = data;
  const barHeight = 300;
  const barOffset = 6;
  const svgOffset = -50;
  return (
    <>
      <Button
        mt="-10px"
        icon={active ? 'power-off' : 'times'}
        content={active ? 'On' : 'Off'}
        selected={active}
        onClick={() => act('active')}
      />
      <Flex>
        <Flex.Item>
          <Box minWidth="300px">
            Depth:
            <ProgressBar
              minValue={0}
              maxValue={max_depth}
              value={depth}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
            Shield:
            <ProgressBar
              minValue={0}
              maxValue={max_shield}
              value={shield_strength}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
            Health:
            <ProgressBar
              minValue={0}
              maxValue={max_health}
              value={health}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
            <br />
            Set Depth:
            <br />
            <NumberInput
              animated
              value={parseFloat(set_depth)}
              width="75px"
              unit="km"
              minValue={0}
              maxValue={max_depth}
              step={10}
              onChange={(value) =>
                act('set_depth', {
                  set_depth: value,
                })
              }
            />
            <br />
            <Box mb={2} mt={2}>
              <Tooltip content="Power * Modifier">
                <Box>
                  Shielding Strength:
                  {' ' + shield_strength_change.toFixed(2)}
                  <br />
                </Box>
              </Tooltip>

              <BlockQuote color="">
                Total Gas Power: {gas_power.toFixed(2)}
                <br />
                Average Gas Modifier: {gas_modifier.toFixed(2)}
                <br />
              </BlockQuote>
            </Box>
            Fracking Efficiency:
            <br />
            {fracking_eff.toFixed(2)}
            <br />
            <br />
            <Collapsible title="Production Table" overflow="overlay">
              {DisplayGasOutput(mols_produced)}
            </Collapsible>
            <br />
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box width="10px" />
        </Flex.Item>
        <Flex.Item>
          <svg width="200" height={barHeight + 20}>
            <rect
              x={140 + svgOffset}
              y={barOffset}
              width="10"
              height={barHeight}
              fill="black"
              stroke="grey"
            />
            <Tooltip content={'Depth: ' + depth + ' km'}>
              <rect
                x={143 + svgOffset}
                y={barOffset}
                width="4"
                height={barHeight * (depth / max_depth)}
                fill="grey"
              />
            </Tooltip>
            {DisplayGasBar(
              125 + svgOffset,
              o2_constants,
              max_depth,
              barHeight,
              'blue',
              'O2',
            )}{' '}
            {/* O2 */}
            {DisplayGasBar(
              115 + svgOffset,
              n2_constants,
              max_depth,
              barHeight,
              'red',
              'N2',
            )}{' '}
            {/* N2 */}
            {DisplayGasBar(
              125 + svgOffset,
              plas_constants,
              max_depth,
              barHeight,
              'purple',
              'Plasma',
            )}{' '}
            {/* Plasma */}
            {DisplayGasBar(
              105 + svgOffset,
              co2_constants,
              max_depth,
              barHeight,
              'grey',
              'CO2',
            )}{' '}
            {/* CO2 */}
            {DisplayGasBar(
              115 + svgOffset,
              n2o_constants,
              max_depth,
              barHeight,
              'white',
              'N2O',
            )}{' '}
            {/* N2O */}
            {DisplayGasBar(
              125 + svgOffset,
              nob_constants,
              max_depth,
              barHeight,
              'teal',
              'Hypernoblium',
            )}{' '}
            {/* Hypernoblium */}
            {DisplayGasBar(
              115 + svgOffset,
              bz_constants,
              max_depth,
              barHeight,
              'brown',
              'BZ',
            )}{' '}
            {/* BZ */}
            {DisplayGasBar(
              95 + svgOffset,
              plox_constants,
              max_depth,
              barHeight,
              'yellow',
              'Pluoxium',
            )}{' '}
            {/* Pluoxium */}
            {DisplayGasBar(
              105 + svgOffset,
              trit_constants,
              max_depth,
              barHeight,
              'lawngreen',
              'Tritium',
            )}{' '}
            {/* Tritium */}
            {DisplayValues(155 + svgOffset, barHeight, data)}
          </svg>
        </Flex.Item>
      </Flex>
      {DisplayWarning(data.warning_message)}
    </>
  );
};
