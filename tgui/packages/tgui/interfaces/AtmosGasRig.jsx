import { useBackend } from '../backend';
import { Section, ProgressBar, NumberInput, Box, Button, Table, Flex, BlockQuote, NoticeBox } from '../components';
import { Window } from '../layouts';

export const AtmosGasRig = (props) => {
  return (
    <Window theme="ntos" width={500} height={425}>
      <Window.Content>{AtmosGasRigTemplate(props)}</Window.Content>
    </Window>
  );
};

const DisplayWarning = (warning, message) => {
  if (warning) {
    return <NoticeBox color="red">{message}</NoticeBox>;
  }
  return <Box />;
};

export const AtmosGasRigTemplate = (props) => {
  const { act, data } = useBackend();
  const depth = data.depth;
  const barHeight = 300;
  return (
    <Section title="Advanced Gas Rig:" height="100%">
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
              width="95px"
              unit="Meters"
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
            Shielding Strength:
            <br />
            {data.shield_strength_change}
            <br />
            <BlockQuote color="">
              Gas Power: {data.gas_power}
              <br />
              Specific Heat: {data.specific_heat}
              <br />
            </BlockQuote>
            Fracking Efficiency:
            <br />
            {data.fracking_eff}
            <br />
            <br />
            {DisplayWarning(data.needs_repairs, 'Repairs needed! Use plasteel to replace damaged components.')}
          </Box>
        </Flex.Item>
        <Flex.Item>
          <Box width="10px" />
        </Flex.Item>
        <Flex.Item>
          <svg width="400" height="1000">
            <rect x="140" y="0" width="10" height={barHeight} fill="black" stroke="grey" />
            <rect x="143" y="0" width="4" height={barHeight * (depth / data.max_depth)} fill="grey" />
            <rect
              x="125"
              y={barHeight * (data.o2_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.o2_constants[1] - data.o2_constants[0]) / data.max_depth)}
              fill="blue"
            />
            <text x="100" y={barHeight * (data.o2_constants[0] / data.max_depth) + 20} fill="white" fontSize="12px">
              O2
            </text>
            <rect
              x="115"
              y={barHeight * (data.n2_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.n2_constants[1] - data.n2_constants[0]) / data.max_depth)}
              fill="red"
            />
            <text x="90" y={barHeight * (data.n2_constants[0] / data.max_depth) + 20} fill="white" fontSize="12px">
              N2
            </text>
            <rect
              x="105"
              y={barHeight * (data.plas_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.plas_constants[1] - data.plas_constants[0]) / data.max_depth)}
              fill="purple"
            />
            <text x="75" y={barHeight * (data.plas_constants[0] / data.max_depth)} fill="white" fontSize="12px">
              Plas
            </text>
            <rect
              x="95"
              y={barHeight * (data.co2_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.co2_constants[1] - data.co2_constants[0]) / data.max_depth)}
              fill="grey"
            />
            <text x="60" y={barHeight * (data.co2_constants[0] / data.max_depth) + 30} fill="white" fontSize="12px">
              CO2
            </text>
            <rect
              x="95"
              y={barHeight * (data.n2o_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.n2o_constants[1] - data.n2o_constants[0]) / data.max_depth)}
              fill="white"
            />
            <text x="60" y={barHeight * (data.n2o_constants[0] / data.max_depth) + 30} fill="white" fontSize="12px">
              N2O
            </text>
            <rect
              x="85"
              y={barHeight * (data.nob_constants[0] / data.max_depth)}
              width="10"
              height={barHeight * ((data.nob_constants[1] - data.nob_constants[0]) / data.max_depth)}
              fill="aqua"
            />
            <text x="35" y={barHeight * (data.nob_constants[0] / data.max_depth) + 10} fill="white" fontSize="12px">
              Nobium
            </text>
          </svg>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
