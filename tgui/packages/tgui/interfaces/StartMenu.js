

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, Flex, Stack, Section, Divider, NoticeBox, Table } from '../components';
import { Window } from '../layouts';

export const StartMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    state,
  } = data;
  switch (state) {
    case 0:
      return <StartMenuInitial />;
    case 2:
      return <JoinLobby />;
  }
  return (
    <Window
      theme="generic"
      width={280}
      height={100}
      minHeight="200px">
      <Window.Content>
        You are in a bugged state!
        <Button
          icon="long-arrow-alt-left"
          content="Return"
          onClick={() => act('return_main')} />
      </Window.Content>
    </Window>
  );
};

const JoinLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobby_list = [],
    selected_lobby = null,
  } = data;
  return (
    <Window
      theme="generic"
      width={600}
      height={480}
      minHeight="200px">
      <Window.Content>
        <Flex direction="row" height="100%">
          <Flex.Item shrink={0} basis="200px">
            <Flex direction="column" height="100%">
              <Flex.Item grow={1} overflowY="scroll">
                {lobby_list.length === 0 && (
                  <NoticeBox mt={1}>
                    There are currently no joinable lobbies.
                    <Button
                      mt={1}
                      width="100%"
                      content="Create Lobby"
                      icon="rocket"
                      onClick={() => act('create_lobby')} />
                  </NoticeBox>
                )}
              </Flex.Item>
              <Flex.Item shrink={0}>
                <Button
                  width="100%"
                  fontSize={1.75}
                  icon="long-arrow-alt-left"
                  content="Return"
                  onClick={() => act('return_main')} />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item grow={1} fontSize={2} width="100%" m="10px">
            <Flex direction="column" height="100%">
              <Flex.Item shrink={0}>
                <Table>
                  <Table.Row>
                    <Table.Cell>Name</Table.Cell>
                    <Table.Cell color="grey" textAlign="right">Ship Name Very Long</Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell>Integrity</Table.Cell>
                    <Table.Cell color="grey" textAlign="right">100/300</Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell>Private</Table.Cell>
                    <Table.Cell color="grey" textAlign="right">Yes</Table.Cell>
                  </Table.Row>
                </Table>
              </Flex.Item>
              <Flex.Item
                grow={1}
                mt={3}
                mb={3}
                width="100%">
                <Section
                  width="90%"
                  height="100%"
                  ml="5%"
                  overflowY="scroll"
                  title="Crew"
                  fontSize={1.35}>
                  <Box width="100%">
                    <Flex direction="row">
                      <Flex.Item grow={1}>Burnard Silkwind</Flex.Item>
                      <Flex.Item shrink={0}>
                        <Box
                          inline
                          className={`job-icon16x16 job-icon-hudcaptain`}
                          m="5px" />
                      </Flex.Item>
                    </Flex>
                    <Flex direction="row">
                      <Flex.Item grow={1}>Burnard Silkwind</Flex.Item>
                      <Flex.Item shrink={0}>
                        <Box
                          inline
                          className={`job-icon16x16 job-icon-hudcaptain`}
                          m="5px" />
                      </Flex.Item>
                    </Flex>
                  </Box>
                </Section>
              </Flex.Item>
              <Flex.Item shrink={0} ml="30px" mb="10px" mt="5px" mr="30px">
                <Button
                  width="100%"
                  icon="user-plus"
                  content="Join Crew"
                  disabled={1}
                  tooltip={(
                    <Box fontSize={1.2}>
                      This lobby is private, ask the owner to add you
                      to the ship&#39;s whitelist!
                    </Box>
                  )} />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const StartMenuInitial = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Window
      theme="generic"
      width={280}
      height={270}
      minHeight="200px">
      <Window.Content>
        <Box width="100%" textAlign="center" fontSize="22px">Beestation Logo</Box>
        <Divider />
        <Stack vertical fill mt="10px" ml="15px" mr="15px">
          <Stack.Item basis="25%">
            <Button
              content="Setup Character"
              width="100%"
              fontSize="22px"
              onClick={() => act('setup_character')} />
          </Stack.Item>
          <Stack.Item basis="25%">
            <Button
              content="Create Lobby"
              width="100%"
              fontSize="22px"
              onClick={() => act('create_lobby')} />
          </Stack.Item>
          <Stack.Item basis="25%">
            <Button
              content="Join Lobby"
              width="100%"
              fontSize="22px"
              onClick={() => act('join_lobby')} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
