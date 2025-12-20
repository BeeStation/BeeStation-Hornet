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

const DisplayValues = (position, barHeight, depthMin, depthMax) => {
  // Show 20 intermediate tick values between depthMax (top) and depthMin (bottom)
  const count = 20;
  let items = [];
  const range = depthMax - depthMin || 1;
  for (let i = 0; i <= count; i++) {
    // produce descending values: top = depthMax, bottom = depthMin
    items.push(Math.round(depthMax - (range / count) * i));
  }
  return items.map((item, index) => {
    const displayKm = (item / 1000).toFixed(0) + 'km';
    return (
      <>
        <text
          key={item}
          x={position}
          y={barHeight * (index / count) + 12}
          fill="white"
          fontSize="11px"
          fontFamily="Consolas, 'Courier New', monospace"
        >
          {displayKm}
        </text>
        <rect
          x={position - 15}
          width="10"
          height="1"
          y={barHeight * (index / count) + 6}
          fill="grey"
        />
      </>
    );
  });
};

const DisplayGasBar = (
  position_bar,
  constant,
  depthMin,
  depthMax,
  barHeight,
  color,
  text,
) => {
  const barOffset = 6;
  const range = depthMax - depthMin || 1;
  const clamp = (v) => Math.max(depthMin, Math.min(depthMax, v));
  // Ensure we have ordered bounds
  const a = clamp(constant[0]);
  const b = clamp(constant[1]);
  const low = Math.min(a, b);
  const high = Math.max(a, b);
  // Flip orientation: top corresponds to depthMax, bottom to depthMin
  const normTop = (depthMax - high) / range;
  const normBottom = (depthMax - low) / range;
  const yStart = barHeight * normTop + barOffset;
  const height = Math.max(0, barHeight * (normBottom - normTop));
  return (
    <Tooltip content={text}>
      <rect
        x={position_bar}
        y={yStart}
        width="10"
        height={height}
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
    max_extension,
    max_shield,
    shield_strength,
    max_health,
    health,
    extension,
    set_extension,
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
  const depth_min = 80000;
  const depth_max = 100000;
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
            Nozzle Extension:
            <span> {extension}m</span>
            <ProgressBar
              minValue={0}
              maxValue={max_extension}
              value={extension}
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
            Set Nozzle Extension:
            <br />
            <Flex align="center">
              <Flex.Item>
                <NumberInput
                  animated
                  value={Number(set_extension)}
                  width="75px"
                  unit="m"
                  minValue={0}
                  maxValue={max_extension}
                  step={10}
                  onChange={(value) =>
                    act('set_extension', {
                      // send meters (integer) to backend
                      set_extension: Math.round(value),
                    })
                  }
                />
              </Flex.Item>
              <Flex.Item shrink={0} ml={1}>
                <Button
                  width="40px"
                  onClick={() =>
                    act('set_extension', {
                      set_extension: Math.min(
                        max_extension,
                        Math.round(Number(set_extension) + 50),
                      ),
                    })
                  }
                  content="+50"
                />
              </Flex.Item>
              <Flex.Item shrink={0} ml={1}>
                <Button
                  width="40px"
                  onClick={() =>
                    act('set_extension', {
                      set_extension: Math.max(
                        0,
                        Math.round(Number(set_extension) - 50),
                      ),
                    })
                  }
                  content="-50"
                />
              </Flex.Item>
              <Flex.Item shrink={0} ml={1}>
                <Tooltip content="Stop Extension Adjustment">
                  <Button
                    width="22px"
                    color="orange"
                    icon="stop"
                    onClick={() =>
                      act('set_extension', {
                        // set the pending set_extension value to the current extension
                        set_extension: Math.round(extension),
                      })
                    }
                  />
                </Tooltip>
              </Flex.Item>
              <Flex.Item shrink={0} ml={1}>
                <Tooltip content="SCRAM: Immediately retract nozzle to minimum extension.">
                  <Button
                    width="56px"
                    color="red"
                    content="SCRAM"
                    onClick={() =>
                      act('set_extension', {
                        set_extension: 0,
                      })
                    }
                  />
                </Tooltip>
              </Flex.Item>
            </Flex>
            <Box mb={2} mt={2}>
              {' '}
              <Tooltip content="Current Depth of the Station itself">
                <Box>
                  Station Altitude: {((depth + extension) / 1000).toFixed(1)}km
                </Box>
              </Tooltip>
              <Tooltip content="Current Depth of the Gas Rig Nozzle">
                <Box>Depth at Tip: {(depth / 1000).toFixed(1)}km</Box>
              </Tooltip>
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
            <Tooltip
              content={
                'Station Altitude: ' +
                ((depth + extension) / 1000).toFixed(1) +
                ' km'
              }
            >
              {/* Draw station position indicator (small blip) */}
              <rect
                x={141 + svgOffset}
                y={
                  barOffset +
                  // normalize station depth (depth + extension), flipped so top = depth_max
                  ((depth_max - (depth + extension)) /
                    (depth_max - depth_min || 1)) *
                    barHeight -
                  2
                }
                width="8"
                height="4"
                fill="white"
              />
            </Tooltip>
            <Tooltip content={'Nozzle Extension: ' + extension + ' m'}>
              {/* Draw nozzle extension indicator bar */}
              <rect
                x={143 + svgOffset}
                y={
                  barOffset +
                  // normalize station depth (depth + extension), flipped so top = depth_max
                  ((depth_max - (depth + extension)) /
                    (depth_max - depth_min || 1)) *
                    barHeight
                }
                width="4"
                height={(extension / (depth_max - depth_min || 1)) * barHeight}
                fill="grey"
              />
            </Tooltip>
            {DisplayGasBar(
              105 + svgOffset,
              n2o_constants,
              depth_min,
              depth_max,
              barHeight,
              'white',
              'N2O',
            )}
            {DisplayGasBar(
              115 + svgOffset,
              n2_constants,
              depth_min,
              depth_max,
              barHeight,
              'red',
              'N2',
            )}
            {DisplayGasBar(
              125 + svgOffset,
              o2_constants,
              depth_min,
              depth_max,
              barHeight,
              'blue',
              'O2',
            )}

            {DisplayGasBar(
              105 + svgOffset,
              bz_constants,
              depth_min,
              depth_max,
              barHeight,
              'brown',
              'BZ',
            )}
            {DisplayGasBar(
              115 + svgOffset,
              trit_constants,
              depth_min,
              depth_max,
              barHeight,
              'lawngreen',
              'Tritium',
            )}
            {DisplayGasBar(
              125 + svgOffset,
              plas_constants,
              depth_min,
              depth_max,
              barHeight,
              'purple',
              'Plasma',
            )}

            {DisplayGasBar(
              105 + svgOffset,
              plox_constants,
              depth_min,
              depth_max,
              barHeight,
              'yellow',
              'Pluoxium',
            )}
            {DisplayGasBar(
              115 + svgOffset,
              nob_constants,
              depth_min,
              depth_max,
              barHeight,
              'teal',
              'Hypernoblium',
            )}
            {DisplayGasBar(
              125 + svgOffset,
              co2_constants,
              depth_min,
              depth_max,
              barHeight,
              'grey',
              'CO2',
            )}

            {DisplayValues(155 + svgOffset, barHeight, depth_min, depth_max)}
          </svg>
        </Flex.Item>
      </Flex>
      {DisplayWarning(data.warning_message)}
    </>
  );
};
