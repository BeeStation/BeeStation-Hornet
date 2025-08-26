import { useBackend } from '../backend';
import { Section, ProgressBar, NumberInput, Box, Button, Flex, BlockQuote, NoticeBox, Tooltip } from '../components';
import { Window } from '../layouts';

export const AtmosGasRig = (props) => {
  return (
    <Window theme="ntos" width={480} height={425}>
      <Window.Content>{AtmosGasRigTemplate(props)}</Window.Content>
    </Window>
  );
};

const DisplayWarning = (message) => {
  if (message !== null) {
    return <NoticeBox color="red">{message}</NoticeBox>;
  }
  return <Box />;
};

const DisplayValues = (position, barHeight, data) => {
  const count = 5;
  let items = [];
  for (let i = 0; i <= count; i++) {
    items.push((data.max_depth / count) * i);
  }
  return items.map((item, index) => (
    <>
      <text key={item} x={position} y={barHeight * (index / count) + 12} fill="white" fontSize="12px">
        {item}
      </text>
      <rect x={position - 15} width="10" height="1" y={barHeight * (index / count) + 6} fill="grey" />
    </>
  ));
};

const DisplayGasBar = (position_bar, constant, data, barHeight, color, text) => {
  const barOffset = 6;
  return (
    <Tooltip content={text}>
      <rect
        x={position_bar}
        y={barHeight * (constant[0] / data.max_depth) + barOffset}
        width="10"
        height={barHeight * ((constant[1] - constant[0]) / data.max_depth)}
        fill={color}
      />
    </Tooltip>
  );
};

export const AtmosGasRigTemplate = (props) => {
  const { act, data } = useBackend();
  const depth = data.depth;
  const barHeight = 300;
  const barOffset = 6;
  const svgOffset = -50;
  return (
    <Section title="Advanced Gas Rig:" height="100%">
      <Button
        mt="-10px"
        icon={data.active ? 'power-off' : 'times'}
        content={data.active ? 'On' : 'Off'}
        selected={data.active}
        onClick={() => act('active')}
      />
      <Flex>
        <Flex.Item>
          <Box minWidth="300px">
            Depth:
            <ProgressBar
              minValue={0}
              maxValue={data.max_depth}
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
              maxValue={data.max_shield}
              value={data.shield_strength}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
            Health:
            <ProgressBar
              minValue={0}
              maxValue={data.max_health}
              value={data.health}
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
              value={parseFloat(data.set_depth)}
              width="75px"
              unit="km"
              minValue={0}
              maxValue={data.max_depth}
              step={10}
              onChange={(value) =>
                act('set_depth', {
                  set_depth: value,
                })
              }
            />
            <br />
            <Box mb={2} mt={2}>
              Shielding Strength:
              <br />
              {data.shield_strength_change.toFixed(2)}
              <br />
              <BlockQuote color="">
                Gas Power: {data.gas_power.toFixed(2)}
                <br />
                Specific Heat: {data.specific_heat.toFixed(2)}
                <br />
              </BlockQuote>
            </Box>
            Fracking Efficiency:
            <br />
            {data.fracking_eff.toFixed(2)}
            <br />
            <br />
            <br />
            {DisplayWarning(data.warning_message)}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box width="10px" />
        </Flex.Item>
        <Flex.Item>
          <svg width="200" height="1000">
            <rect x={140 + svgOffset} y={barOffset} width="10" height={barHeight} fill="black" stroke="grey" />
            <rect x={143 + svgOffset} y={barOffset} width="4" height={barHeight * (depth / data.max_depth)} fill="grey" />
            {DisplayGasBar(125 + svgOffset, data.o2_constants, data, barHeight, 'blue', 'O2')} {/* O2 */}
            {DisplayGasBar(115 + svgOffset, data.n2_constants, data, barHeight, 'red', 'N2')} {/* N2 */}
            {DisplayGasBar(105 + svgOffset, data.plas_constants, data, barHeight, 'purple', 'Plasma')} {/* Plasma */}
            {DisplayGasBar(125 + svgOffset, data.co2_constants, data, barHeight, 'grey', 'CO2')} {/* CO2 */}
            {DisplayGasBar(125 + svgOffset, data.n2o_constants, data, barHeight, 'white', 'N2O')} {/* N2O */}
            {DisplayGasBar(115 + svgOffset, data.nob_constants, data, barHeight, 'teal', 'Hypernoblium')} {/* Hypernoblium */}
            {DisplayGasBar(125 + svgOffset, data.bz_constants, data, barHeight, 'brown', 'BZ')} {/* BZ */}
            {DisplayGasBar(115 + svgOffset, data.plox_constants, data, barHeight, 'yellow', 'Plouxium')} {/* Plouxium */}
            {DisplayValues(155 + svgOffset, barHeight, data)}
          </svg>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
