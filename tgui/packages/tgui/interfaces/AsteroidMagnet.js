import { toTitleCase } from 'common/string';
import { Box, Button, Section, Table, Flex, NoticeBox } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const AsteroidMagnet = (props, context) => {
  const { act, data } = useBackend(context);
  const { area_connected = false, area_width = 0, area_height = 0, nearby_objects = [] } = data;

  const [targetObject, setTargetObject] = useLocalState(context, 'targetObject', '');

  return (
    <Window width={350} height={550}>
      <Window.Content scrollable>
        <Flex direction="column">
          <Flex.Item>
            <Section title="Magnet Operations">
              {area_connected ? (
                <Box>
                  <NoticeBox color="green">
                    Max Asteroid Size: {area_width}x{area_height}
                  </NoticeBox>
                  {targetObject ? (
                    <NoticeBox>
                      <Box>Target: {targetObject}</Box>
                      <Button
                        color="green"
                        mt="5px"
                        width="100%"
                        textAlign="center"
                        onClick={() =>
                          act('activate', {
                            target: targetObject,
                          })
                        }>
                        Activate
                      </Button>
                    </NoticeBox>
                  ) : (
                    <NoticeBox color="red">No target selected</NoticeBox>
                  )}
                  <NoticeBox>
                    <Button color="red" mt="5px" width="100%" textAlign="center" onClick={() => act('eject')}>
                      Eject Bay Contents
                    </Button>
                  </NoticeBox>
                </Box>
              ) : (
                <NoticeBox color="red">Not linked</NoticeBox>
              )}
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section title="Nearby Objects">
              <Table>
                <Table.Row header>
                  <Table.Cell>Name</Table.Cell>
                  <Table.Cell collapsing textAlign="right">
                    Distance
                  </Table.Cell>
                  <Table.Cell textAlign="right">Action</Table.Cell>
                </Table.Row>
                {nearby_objects.map((nearby) => (
                  <Table.Row key={nearby.name}>
                    <Table.Cell>{toTitleCase(nearby.name)}</Table.Cell>
                    <Table.Cell collapsing textAlign="right">
                      <Box color="label" inline>
                        {nearby.distance}
                      </Box>
                    </Table.Cell>
                    <Table.Cell textAlign="right">
                      <Button inline onClick={() => setTargetObject(nearby.name)}>
                        Select
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
