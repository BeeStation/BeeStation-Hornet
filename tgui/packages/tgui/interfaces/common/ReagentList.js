import { Box, Button, Table, NumberInput } from '../../components';
import { useBackend, useLocalState } from '../../backend';

export const ReagentList = (props, context) => {
  const { content } = props;
  const { act } = useBackend(context);
  const [
    amount,
    setAmount,
  ] = useLocalState(context, "amount", 1);
  return (
    <Table height="100%">
      {content.map(chemical => (
        <Table.Row
          key={chemical.name}
          color="label"
          height="100%">
          <Table.Cell>
            {chemical.volume} units of {chemical.name}
          </Table.Cell>
          <Table.Cell
            collapsing
            verticalAlign="middle">
            <Button
              icon="minus"
              onClick={() => { amount !== 0 && (
                setAmount(amount-1)); }} />
          </Table.Cell>
          <Table.Cell
            collapsing
            verticalAlign="middle">
            <NumberInput
              value={amount}
              minValue={0}
              maxValue={chemical.volume}
              onChange={(e, value) => setAmount(value)} />
          </Table.Cell>
          <Table.Cell
            collapsing
            verticalAlign="middle">
            <Button
              icon="plus"
              onClick={() => { amount !== chemical.volume && (
                setAmount(amount+1)); }} />
          </Table.Cell>
          <Table.Cell
            collapsing
            verticalAlign="right">
            <Button
              icon="plus-circle"
              content="Add"
              onClick={() => act("add", {
                reagent: chemical,
                amount: amount,
              })} />
          </Table.Cell>
        </Table.Row>


      ))}
    </Table>
  );
};
