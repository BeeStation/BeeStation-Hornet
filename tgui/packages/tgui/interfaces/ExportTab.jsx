import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Chart,
  Flex,
  Icon,
  ProgressBar,
  Section,
  Table,
} from '../components';

const getDemandLabel = (ratio) => {
  if (ratio >= 75) return 'High';
  if (ratio >= 40) return 'Medium';
  if (ratio > 0) return 'Low';
  return 'None';
};

const getDemandIcon = (ratio) => {
  if (ratio >= 75) return 'arrow-trend-up';
  if (ratio >= 40) return 'arrows-left-right';
  return 'arrow-trend-down';
};

const getDemandTextColor = (ratio) => {
  if (ratio >= 75) return '#4caf50';
  if (ratio >= 40) return '#ff9800';
  if (ratio > 0) return '#f44336';
  return '#888';
};

const CHART_STROKE_COLOR = 'rgba(0, 181, 173, 1)';
const CHART_FILL_COLOR = 'rgba(0, 181, 173, 0.25)';

export const ExportTab = (props) => {
  const { act, data } = useBackend();
  const { item_exports = [], gas_exports = [] } = data;
  const [selected, setSelected] = useState(null);

  // Find the currently selected item or gas for the chart
  const allItems = [
    ...gas_exports.map((g) => ({ ...g, type: 'gas' })),
    ...item_exports.map((i) => ({ ...i, type: 'item' })),
  ];
  const selectedEntry =
    allItems.find((e) => e.name === selected) || allItems[0] || null;
  const history = selectedEntry?.history || [];
  const chartData = history.map((val, i) => [i, val]);
  const maxChart = Math.max(100, ...history);

  return (
    <Box>
      {/* Demand Trend Chart */}
      <Section
        title={
          <Box inline>
            <Icon name="chart-line" mr={1} />
            <Box inline color="black">
              {'Demand Trend: '}
            </Box>
            <Box inline color="black">
              {selectedEntry ? selectedEntry.name : 'No data'}
            </Box>
          </Box>
        }
        buttons={
          <Button
            icon="print"
            content="Print Export Prices"
            onClick={() => act('PrintExports')}
          />
        }
      >
        {chartData.length > 1 ? (
          <Chart.Line
            height="120px"
            data={chartData}
            rangeX={[0, chartData.length - 1]}
            rangeY={[0, maxChart]}
            strokeColor={CHART_STROKE_COLOR}
            fillColor={CHART_FILL_COLOR}
          />
        ) : (
          <Box height="120px" textAlign="center" pt={4} color="label" italic>
            <Icon name="clock" mr={1} />
            Demand history will appear as the market fluctuates.
            {selectedEntry ? ' Select a row to track it.' : ''}
          </Box>
        )}
        {selectedEntry && (
          <Flex mt={1} justify="space-around" textAlign="center">
            <Flex.Item>
              <Box color="label" fontSize={0.85}>
                Current Demand
              </Box>
              <Box bold fontSize={1.1}>
                {selectedEntry.demand_ratio}%
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box color="label" fontSize={0.85}>
                {selectedEntry.type === 'gas' ? 'Base Value' : 'Base Price'}
              </Box>
              <Box bold fontSize={1.1}>
                {selectedEntry.type === 'gas'
                  ? selectedEntry.base_value + ' cr/mol'
                  : selectedEntry.base_price + ' cr'}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box color="label" fontSize={0.85}>
                {selectedEntry.type === 'gas'
                  ? 'Effective Value'
                  : 'Current Price'}
              </Box>
              <Box bold fontSize={1.1} color="good">
                {selectedEntry.type === 'gas'
                  ? selectedEntry.effective_value + ' cr/mol'
                  : selectedEntry.effective_price + ' cr'}
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box color="label" fontSize={0.85}>
                Stock
              </Box>
              <Box bold fontSize={1.1}>
                {selectedEntry.current_demand} / {selectedEntry.max_demand}
              </Box>
            </Flex.Item>
          </Flex>
        )}
      </Section>
      {/* Gas Exports Table */}
      <Section
        title={
          <Box inline>
            <Icon name="smog" mr={1} />
            Gas Exports
          </Box>
        }
      >
        <Table>
          <Table.Row bold color="label" fontSize={0.95}>
            <Table.Cell p={0.5}>Gas</Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Base
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Current
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Demand
            </Table.Cell>
          </Table.Row>
          {gas_exports.map((gas) => {
            const isSelected = selected === gas.name;
            return (
              <Table.Row
                key={gas.name}
                className="candystripe"
                onClick={() => setSelected(gas.name)}
                style={{ cursor: 'pointer' }}
              >
                <Table.Cell bold p={0.5}>
                  <Box
                    inline
                    style={{
                      borderLeft: isSelected
                        ? '3px solid ' + CHART_STROKE_COLOR
                        : '3px solid transparent',
                      paddingLeft: '6px',
                    }}
                  >
                    <Box inline color={gas.color} mr={0.5}>
                      {'\u2B24'}
                    </Box>
                    {gas.name}
                  </Box>
                </Table.Cell>
                <Table.Cell
                  p={0.5}
                  textAlign="center"
                  color="label"
                  fontSize={0.9}
                >
                  {gas.base_value} cr/mol
                </Table.Cell>
                <Table.Cell p={0.5} textAlign="center" bold>
                  {gas.effective_value} cr/mol
                </Table.Cell>
                <Table.Cell p={0.5} width="200px">
                  <Flex align="center">
                    <Flex.Item mr={0.5}>
                      <Icon
                        name={getDemandIcon(gas.demand_ratio)}
                        color={getDemandTextColor(gas.demand_ratio)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <ProgressBar
                        value={gas.demand_ratio}
                        maxValue={100}
                        ranges={{
                          good: [60, Infinity],
                          average: [30, 60],
                          bad: [-Infinity, 30],
                        }}
                      >
                        {getDemandLabel(gas.demand_ratio)} ({gas.demand_ratio}%)
                      </ProgressBar>
                    </Flex.Item>
                  </Flex>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      </Section>
      {/* Material Exports Table */}
      <Section
        title={
          <Box inline>
            <Icon name="gem" mr={1} />
            Ores, Materials &amp; Alloys
          </Box>
        }
      >
        <Table>
          <Table.Row bold color="label" fontSize={0.95}>
            <Table.Cell p={0.5}>Item</Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Base
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Current
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Demand
            </Table.Cell>
          </Table.Row>
          {item_exports.map((item) => {
            const isSelected = selected === item.name;
            return (
              <Table.Row
                key={item.name}
                className="candystripe"
                onClick={() => setSelected(item.name)}
                style={{ cursor: 'pointer' }}
              >
                <Table.Cell bold p={0.5}>
                  <Box
                    inline
                    style={{
                      borderLeft: isSelected
                        ? '3px solid ' + CHART_STROKE_COLOR
                        : '3px solid transparent',
                      paddingLeft: '6px',
                    }}
                  >
                    {item.name}
                  </Box>
                </Table.Cell>
                <Table.Cell
                  p={0.5}
                  textAlign="center"
                  color="label"
                  fontSize={0.9}
                >
                  {item.base_price} cr
                </Table.Cell>
                <Table.Cell p={0.5} textAlign="center" bold>
                  {item.effective_price} cr
                </Table.Cell>
                <Table.Cell p={0.5} width="200px">
                  <Flex align="center">
                    <Flex.Item mr={0.5}>
                      <Icon
                        name={getDemandIcon(item.demand_ratio)}
                        color={getDemandTextColor(item.demand_ratio)}
                      />
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <ProgressBar
                        value={item.demand_ratio}
                        maxValue={100}
                        ranges={{
                          good: [60, Infinity],
                          average: [30, 60],
                          bad: [-Infinity, 30],
                        }}
                      >
                        {getDemandLabel(item.demand_ratio)} ({item.demand_ratio}
                        %)
                      </ProgressBar>
                    </Flex.Item>
                  </Flex>
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      </Section>
    </Box>
  );
};
