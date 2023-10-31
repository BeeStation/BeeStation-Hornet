import { toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Button, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';

export const MaterialDepositMachine = (props, context) => {
  const { act, data } = useBackend(context);
  const { materials } = data;
  return (
    <Window width={440} height={550}>
      <Window.Content scrollable>
        <Section title="Materials">
          <Table>
            {materials.map((material) => (
              <MaterialRow
                key={material.id}
                material={material}
                onRelease={(amount) =>
                  act('Eject', {
                    id: material.id,
                    sheets: amount,
                  })
                }
              />
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};

const MaterialRow = (props, context) => {
  const { material, onRelease } = props;

  const [amount, setAmount] = useLocalState(context, 'amount' + material.name, 1);

  const amountAvailable = Math.floor(material.amount);
  return (
    <Table.Row>
      <Table.Cell>{toTitleCase(material.name).replace('Alloy', '')}</Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {material.value && material.value + ' cr'}
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        <Box mr={2} color="label" inline>
          {amountAvailable} sheets
        </Box>
      </Table.Cell>
      <Table.Cell collapsing>
        <NumberInput
          width="32px"
          step={1}
          stepPixelSize={5}
          minValue={1}
          maxValue={50}
          value={amount}
          onChange={(e, value) => setAmount(value)}
        />
        <Button disabled={amountAvailable < 1} content="Release" onClick={() => onRelease(amount)} />
      </Table.Cell>
    </Table.Row>
  );
};
