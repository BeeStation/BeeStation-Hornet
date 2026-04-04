import { useBackend } from '../backend';
import { Box, Button, ProgressBar, Section, Table } from '../components';

const getDemandColor = (ratio) => {
  if (ratio >= 75) return 'good';
  if (ratio >= 40) return 'average';
  if (ratio > 0) return 'bad';
  return 'bad';
};

const getDemandLabel = (ratio) => {
  if (ratio >= 75) return 'High';
  if (ratio >= 40) return 'Medium';
  if (ratio > 0) return 'Low';
  return 'None';
};

export const ExportTab = (props) => {
  const { act, data } = useBackend();
  const { item_exports = [], gas_exports = [] } = data;

  return (
    <Box>
      <Section
        title="Gas Exports"
        buttons={
          <Button
            icon="print"
            content="Print Export Prices"
            onClick={() => act('PrintExports')}
          />
        }
      >
        <Table>
          <Table.Row bold italic color="label" fontSize={1.1}>
            <Table.Cell p={0.5}>Gas</Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Base Price
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Current Price
            </Table.Cell>
            <Table.Cell p={0.5} collapsing textAlign="center">
              Demand
            </Table.Cell>
          </Table.Row>
          {gas_exports.map((gas) => (
            <Table.Row key={gas.name}>
              <Table.Cell bold p={0.5}>
                <Box inline color={gas.color}>
                  {'\u2B24 '}
                </Box>
                {gas.name}
              </Table.Cell>
              <Table.Cell p={0.5} textAlign="center" color="label">
                {gas.base_value} cr/mol
              </Table.Cell>
              <Table.Cell p={0.5} textAlign="center" bold>
                {gas.effective_value} cr/mol
              </Table.Cell>
              <Table.Cell p={0.5} width="200px">
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
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
      <Section title="Material &amp; Item Exports">
        <Table>
          <Table.Row bold italic color="label" fontSize={1.1}>
            <Table.Cell p={0.5}>Item</Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Base Price
            </Table.Cell>
            <Table.Cell p={0.5} textAlign="center">
              Current Price
            </Table.Cell>
            <Table.Cell p={0.5} collapsing textAlign="center">
              Demand
            </Table.Cell>
          </Table.Row>
          {item_exports.map((item) => (
            <Table.Row key={item.name}>
              <Table.Cell bold p={0.5}>
                {item.name}
              </Table.Cell>
              <Table.Cell p={0.5} textAlign="center" color="label">
                {item.base_price} cr
              </Table.Cell>
              <Table.Cell p={0.5} textAlign="center" bold>
                {item.effective_price} cr
              </Table.Cell>
              <Table.Cell p={0.5} width="200px">
                <ProgressBar
                  value={item.demand_ratio}
                  maxValue={100}
                  ranges={{
                    good: [60, Infinity],
                    average: [30, 60],
                    bad: [-Infinity, 30],
                  }}
                >
                  {getDemandLabel(item.demand_ratio)} ({item.demand_ratio}%)
                </ProgressBar>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Box>
  );
};
