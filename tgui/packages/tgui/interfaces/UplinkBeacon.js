import { Button, NoticeBox, Table } from 'tgui/components';
import { Window } from '../layouts';
import { useBackend } from '../backend';

export const UplinkBeacon = (props, context) => {
  const { act, data } = useBackend(context);
  const { frequency } = data;
  let channel = 'green';
  switch (frequency) {
    case 0:
      channel = 'green';
      break;
    case 1:
      channel = 'purple';
      break;
    case 2:
      channel = 'yellow';
      break;
    case 3:
      channel = 'orange';
      break;
    case 4:
      channel = 'red';
      break;
    case 5:
      channel = 'black';
      break;
    case 6:
      channel = 'white';
      break;
    case 7:
      channel = 'blue';
      break;
    case 8:
      channel = 'brown';
      break;
  }
  return (
    <Window width={300} height={270} theme="syndicate">
      <Window.Content>
        <NoticeBox height="9%" backgroundColor={channel} verticalAlign="middle" textAlign="center">
          Beacon broadcasting on {channel} channel
        </NoticeBox>
        <Table height="90%">
          <Table.Row height="33%" width="100%">
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="green"
                onClick={() =>
                  act('set_freq', {
                    freq: 0,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="purple"
                onClick={() =>
                  act('set_freq', {
                    freq: 1,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="yellow"
                onClick={() =>
                  act('set_freq', {
                    freq: 2,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
          <Table.Row height="33%" width="100%">
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="orange"
                onClick={() =>
                  act('set_freq', {
                    freq: 3,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="red"
                onClick={() =>
                  act('set_freq', {
                    freq: 4,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="black"
                onClick={() =>
                  act('set_freq', {
                    freq: 5,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
          <Table.Row height="33%" width="100%">
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="white"
                onClick={() =>
                  act('set_freq', {
                    freq: 6,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="blue"
                onClick={() =>
                  act('set_freq', {
                    freq: 7,
                  })
                }
              />
            </Table.Cell>
            <Table.Cell width="33%" height="100%">
              <Button
                width="100%"
                height="100%"
                color="brown"
                onClick={() =>
                  act('set_freq', {
                    freq: 8,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        </Table>
      </Window.Content>
    </Window>
  );
};
