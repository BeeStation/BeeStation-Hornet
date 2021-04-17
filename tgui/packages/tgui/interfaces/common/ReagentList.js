import { AnimatedNumber, Box, Button, Table, NumberInput } from '../../components';
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
            <AnimatedNumber
              value={chemical.volume} />
            {chemical.volume < 2 && (
              " unit of "
            ) || (
              " units of "
            )}
            {chemical.name}
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

export const QueueList = (props, context) => {
  const { content = {}, injecting, multiplier } = props;
  const { act } = useBackend(context);
  return (
    <Table height="100%">
      {content.map(queue => (
        <Table.Row
          key={queue.name}
          color="label"
          height="100%">
          <Table.Cell>
            <AnimatedNumber
              value={queue.volume * multiplier} />
            {queue.volume * multiplier < 2 && (
              " unit of "
            ) || (
              " units of "
            )}
            {queue.name}
          </Table.Cell>
          <Table.Cell
            collapsing
            verticalAlign="middle">
            <Button
              icon="minus"
              onClick={() => act("remove", {
                reagent: queue,
              })} />
          </Table.Cell>
        </Table.Row>
      ))}
      {content.length && (
        <Table.Row>
          <Table.Cell>
            {!injecting && (
              <Button
                content="Inject Patient"
                onClick={() => act("inject")} />
            ) || (
              <Button
                content="Stop injecting"
                color="danger"
                onClick={() => act("stop_injecting")} />
            )}
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Clear queue"
              onClick={() => act('remove_all')} />
          </Table.Cell>
          <Table.Cell>
            <Button
              content="Destroy"
              color="danger"
              onClick={() => act("destroy")} />
          </Table.Cell>
        </Table.Row>) || ("")}
    </Table>
  );
};

export const ReagentListPerson = props => {
  const { content } = props;
  return (
    <Table height="100%">
      {content.map(chemical => (
        <Table.Row
          key={chemical.name}
          color="label"
          height="100%">
          <Table.Cell>
            <AnimatedNumber
              value={chemical.volume} />
            {chemical.volume < 2 && (
              " unit of "
            ) || (
              " units of "
            )}
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
