

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Input, Flex, Stack, Section, Divider, NoticeBox, Table, TextArea, Dropdown } from '../components';
import { Window } from '../layouts';

export const StartMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    state,
  } = data;
  switch (state) {
    case 0:
      return <StartMenuInitial />;
    case 1:
      return <CreateLobby />;
    case 2:
      return <JoinLobby />;
  }
  return (
    <Window
      theme="generic"
      width={280}
      height={100}
      minHeight="200px"
      canClose={false}>
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

const CreateLobby = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    lobby_id,
    lobby_member_list,
    lobby_can_join,
    lobby_private,
    lobby_name,
    is_host = false,
    selectable_ships = [],
    selected_ship = null,
    faction_flags = 0,
    selected_faction = 0,
  } = data;

  const [
    hasEdits,
    setHasEdits,
  ] = useLocalState(context, 'hasEdits', 0);

  let ship_options = Array.from(selectable_ships.map(e => e.name));

  return (
    <Window
      theme="generic"
      width={600}
      height={480}
      canClose={false}>
      <Window.Content>
        <Flex height="100%" direction="row">
          <Flex.Item basis="360px">
            <Flex height="100%" direction="column">
              <Flex.Item grow={3} m="3px">
                <Section width="100%" height="100%" title={lobby_name}>
                  <Flex direction="row" m="5px">
                    <Flex.Item shrink={0} basis="30%">
                      Ship Name
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Input
                        fluid
                        value={lobby_name}
                        disabled={!is_host}
                        onEnter={(e, value) => {
                          act('set_name', {
                            name: value,
                          });
                          setHasEdits(false);
                        }}
                        onInput={(e, value) => {
                          setHasEdits(true);
                        }} />
                    </Flex.Item>
                    {hasEdits ? (
                      <Flex.Item shrink={0}>
                        <Icon name="pen" m="2px" />
                      </Flex.Item>
                    ) : ("")}
                  </Flex>
                  <Flex direction="row" m="5px">
                    <Flex.Item shrink={0} basis="30%">
                      Ship
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Dropdown
                        width="100%"
                        disabled={!is_host}
                        options={ship_options}
                        onSelected={value => act('set_ship', {
                          ship_id: value,
                        })}
                        selected={selected_ship && selected_ship.name} />
                    </Flex.Item>
                  </Flex>
                  <Flex direction="row" m="5px">
                    <Flex.Item shrink={0} basis="30%">
                      Faction
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Dropdown
                        width="100%"
                        disabled={!is_host || !selected_ship}
                        options={selected_ship && Object.keys(faction_flags)
                          .filter(element => (faction_flags[element] & selected_ship.faction_flags) !== 0)}
                        onSelected={value => act('set_faction', {
                          faction_flag: faction_flags[value],
                        })}
                        displayText={Object.keys(faction_flags)
                          .find(element => faction_flags[element] === selected_faction) || "None Selected"} />
                    </Flex.Item>
                  </Flex>
                  <Flex direction="row" m="5px">
                    <Flex.Item shrink={0} basis="30%">
                      Status
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Button
                        width="100%"
                        content={lobby_private ? "Private" : "Public"}
                        icon={lobby_private ? "lock" : "lock-open"}
                        onClick={() => act('set_privacy_mode', {
                          new_private: !lobby_private,
                        })}
                        disabled={!is_host} />
                    </Flex.Item>
                  </Flex>
                  <Divider />
                  <Flex direction="row" m="5px">
                    <Flex.Item shrink={0} basis="30%">
                      Job Role
                    </Flex.Item>
                    <Flex.Item grow={1}>
                      <Dropdown
                        width="100%"
                        disabled={!selected_ship}
                        options={selected_ship && selected_ship.roles.map(role => (
                          <option key={role.job_name}>
                            {role.job_name} ({role.used}/{role.amount < 100 ? role.amount : "∞"})
                          </option>
                        ))}
                        onSelected={value => act('set_job', {
                          job: value.key,
                        })} />
                    </Flex.Item>
                  </Flex>
                  <Divider />
                  <Flex direction="row" m="5px" mb="0px">
                    <Flex.Item grow={1} m="2px" ml="0px" mr="3px">
                      <Button
                        width="100%"
                        content="Leave Lobby"
                        icon="user-slash"
                        onClick={() => act('return_main')} />
                    </Flex.Item>
                    {is_host && (
                      <Flex.Item grow={1} m="2px" ml="3px" mr="0px">
                        <Button
                          width="100%"
                          content="Start Game"
                          icon="rocket"
                          onClick={() => act('start_game')} />
                      </Flex.Item>
                    )}
                  </Flex>
                </Section>
              </Flex.Item>
              <Flex.Item grow={2} m="3px" height="100%">
                <PlayerList />
              </Flex.Item>
            </Flex>
          </Flex.Item>
          <Flex.Item grow={1}>
            <Flex height="100%" direction="column">
              <Flex.Item grow={1} m="3px">
                <Section title="Equipment" width="100%" height="100%" />
              </Flex.Item>
              <Flex.Item grow={1} m="3px">
                <Section width="100%" height="100%" />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const PlayerList = (props, context) => {

  const { act, data } = useBackend(context);
  const {
    lobby_id,
    lobby_member_list,
    lobby_can_join,
    lobby_private,
    lobby_name,
    is_host = false,
    selectable_ships = [],
    selected_ship = null,
  } = data;

  return (
    <Section
      width="100%"
      height="100%"
      overflowY="scroll"
      title={(
        <Flex direction="row">
          <Flex.Item grow={1} m="2px" ml="0px" mr="3px">
            Players
          </Flex.Item>
          {is_host && (
            <>
              <Flex.Item shrink={0} m="2px" ml="0px" mr="3px" fontSize={0.9}>
                <Button
                  width="100%"
                  content="Whitelist"
                  icon="user-plus"
                  onClick={() => act('whitelist')} />
              </Flex.Item>
              <Flex.Item shrink={0} m="2px" ml="0px" mr="3px" fontSize={0.9}>
                <Button
                  width="100%"
                  content="De-whitelist"
                  icon="user-slash"
                  onClick={() => act('dewhitelist')} />
              </Flex.Item>
            </>
          )}
        </Flex>
      )}>
      {lobby_member_list.map(member => (
        <Flex direction="row" key={member.name}>
          <Flex.Item grow={1}>
            {member.name}
          </Flex.Item>
          {is_host && (
            <Flex.Item shrink={0}>
              <Button
                content="Kick"
                onClick={() => act('kick_player', {
                  ckey: member.name,
                })} />
            </Flex.Item>
          )}
          <Flex.Item shrink={0}>
            <Box
              inline
              className={`job-icon16x16 job-icon-hud${(member.job && member.job.toLowerCase().replace(" ", "")) || "no_id"}`}
              m="2px"
              ml="7px" />
          </Flex.Item>
        </Flex>
      ))}
    </Section>
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
      minHeight="200px"
      canClose={false}>
      <Window.Content>
        <Flex direction="row" height="100%">
          <Flex.Item shrink={0} basis="200px">
            <Flex direction="column" height="100%">
              <Flex.Item grow={1} overflowY="scroll" overflowX="hidden">
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
                <Stack vertical>
                  {lobby_list.map(element => (
                    <Stack.Item
                      key={element.id}>
                      <Section
                        onClick={() => act('select_ship', {
                          lobby_id: element.id,
                        })}>
                        <Flex direction="row" height="60px">
                          <Flex.Item shrink={0} verticalAlign="middle">
                            <Icon name={element.private ? "lock" : "lock-open"} size={2} mt="20px" />
                          </Flex.Item>
                          <Flex.Item grow={1} shrink={1} overflowX="hidden" overflowY="hidden">
                            <Flex direction="column" ml="5px" fontSize={1.3} height="100%">
                              <Flex.Item grow={1} />
                              <Flex.Item grow={0} shrink={0}>{element.owner}</Flex.Item>
                              <Flex.Item grow={0} shrink={0} fontSize={1.3} color="lightgrey">
                                {element.state === 0
                                  ? "In lobby"
                                  : "Playing"}
                              </Flex.Item>
                              <Flex.Item grow={1} />
                            </Flex>
                          </Flex.Item>
                          <Flex.Item shrink={0} fontSize={2} mt="30px">
                            {element.member_count}
                            <Icon name="user" size={1} />
                          </Flex.Item>
                        </Flex>
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
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
            {selected_lobby && (
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
                      <Table.Cell color="grey" textAlign="right">{selected_lobby.private ? "Yes" : "No"}</Table.Cell>
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
                      {selected_lobby.member_list.map(member => (
                        <Flex direction="row" key={member.name}>
                          <Flex.Item grow={1}>
                            {member.name}
                          </Flex.Item>
                          <Flex.Item shrink={0}>
                            <Box
                              inline
                              className={`job-icon16x16 job-icon-hud${(member.job && member.job.toLowerCase().replace(" ", "")) || "no_id"}`}
                              m="5px" />
                          </Flex.Item>
                        </Flex>
                      ))}
                    </Box>
                  </Section>
                </Flex.Item>
                <Flex.Item shrink={0} ml="30px" mb="10px" mt="5px" mr="30px">
                  <Button
                    width="100%"
                    icon="user-plus"
                    content="Join Crew"
                    disabled={!selected_lobby.can_join}
                    tooltip={!selected_lobby.can_join && (
                      <Box fontSize={1.2}>
                        This lobby is private, ask the owner to add you
                        to the ship&#39;s whitelist!
                      </Box>
                    )}
                    onClick={() => act('join_crew', {
                      lobby_id: selected_lobby.id,
                    })} />
                </Flex.Item>
              </Flex>
            )}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const StartMenuInitial = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    is_admin = true,
  } = data;
  return (
    <Window
      theme="generic"
      width={280}
      height={270}
      minHeight="200px"
      canClose={false}>
      <Window.Content>
        <Box width="100%" textAlign="center" fontSize="22px">Beestation Logo</Box>
        <Divider />
        <Stack vertical fill mt="10px" ml="15px" mr="15px">
          <Stack.Item basis={is_admin ? "18%" : "25%"}>
            <Button
              content="Setup Character"
              width="100%"
              icon="id-card-alt"
              fontSize="22px"
              onClick={() => act('setup_character')} />
          </Stack.Item>
          <Stack.Item basis={is_admin ? "18%" : "25%"}>
            <Button
              content="Create Lobby"
              width="100%"
              icon="user-plus"
              fontSize="22px"
              onClick={() => act('create_lobby')} />
          </Stack.Item>
          <Stack.Item basis={is_admin ? "18%" : "25%"}>
            <Button
              content="Join Lobby"
              width="100%"
              fontSize="22px"
              icon="users"
              onClick={() => act('join_lobby')} />
          </Stack.Item>
          {is_admin && (
            <Stack.Item basis={is_admin ? "18%" : "25%"}>
              <Button
                content="Observe"
                icon="ghost"
                width="100%"
                fontSize="22px"
                onClick={() => act('observe')} />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
