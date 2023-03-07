import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { Window } from '../layouts';

export const Smelter = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    allowredeem,
    stored_points,
    materials,
    alloys,
  } = data;
  return (
    <Window
      width={440}
      height={550}>
      <Window.Content scrollable>
        <Section>
          <Table.Row>
            <Table.Cell>
              <Box inline color="label" mr={1}>
                Machine Status:
              </Box>
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                onClick={() => act('Toggle_on')} />
            </Table.Cell>
            {!!allowredeem && (
              <Table.Cell collapsing textAlign="right">
                <Box>
                  <Box inline color="label" mr={1}>
                    Stored Points:
                  </Box>
                  {stored_points}
                  <Button
                    ml={2}
                    content="Redeem"
                    disabled={stored_points === 0}
                    onClick={() => act('Redeem')} />
                </Box>
              </Table.Cell>
            )}
          </Table.Row>
        </Section>
        <Section title="Materials">
          <Table>
            {materials.map(material => (
              <MaterialRow
                key={material.id}
                material={material}
                onRelease={() => act('Material', {
                  id: material.id,
                })} />
            ))}
          </Table>
        </Section>
        <Section title="Alloys">
          <Table>
            {alloys.map(material => (
              <MaterialRow
                key={material.id}
                material={material}
                onRelease={() => act('Alloy', {
                  id: material.id,
                })} />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props, context) => {
  const { material, onRelease } = props;

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row>
      <Table.Cell>
        {toTitleCase(material.name).replace('Alloy', '')}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {amountAvailable} sheets
        </Box>
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          color={material.smelting ? "good" : "bad"}
          content={material.smelting ? "Smelting" : "Not Smelting"}
          onClick={() => onRelease()} />
      </Table.Cell>
    </Table.Row>
  );
};
