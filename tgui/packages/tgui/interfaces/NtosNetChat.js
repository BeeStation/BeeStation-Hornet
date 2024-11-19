import { useBackend } from '../backend';
import { Box, Button, Dimmer, Flex, Icon, Input, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

// byond defines for the program state
const CLIENT_ONLINE = 2;
const CLIENT_AWAY = 1;
const CLIENT_OFFLINE = 0;

const STATUS2TEXT = {
  0: 'Offline',
  1: 'Away',
  2: 'Online',
};

const NoChannelDimmer = (props, context) => {
  const { act, data } = useBackend(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item>
          <Stack ml={-2}>
            <Stack.Item>
              <Icon color="green" name="grin-beam" size={10} />
            </Stack.Item>
            <Stack.Item mt={-8}>
              <Icon name="comment-dots" size={10} />
            </Stack.Item>
            <Stack.Item ml={-1}>
              <Icon color="green" name="smile" size={10} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item fontSize="18px">Click a channel to start chatting!</Stack.Item>
        <Stack.Item fontSize="15px">(If you&apos;re new, you may want to set your username below.)</Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ChannelList = ({ all_channels, active_channel, act }) => (
  <Section title="Channels" fill fluid grow={1} height="fill">
    <Button.Input
      fluid
      content="New Channel..."
      onCommit={(e, value) =>
        act('PRG_newchannel', {
          new_channel_name: value,
        })
      }
    />
    {all_channels.map((channel) => (
      <Button
        fluid
        key={channel.chan}
        content={channel.chan}
        selected={channel.id === active_channel}
        color="transparent"
        onClick={() =>
          act('PRG_joinchannel', {
            id: channel.id,
          })
        }
      />
    ))}
  </Section>
);

const UsernameSection = ({ username, can_admin, adminmode, act }) => (
  <Section title="Username" fill>
    <Box>Username:</Box>
    <Button.Input
      fluid
      content={username + '...'}
      currentValue={username}
      onCommit={(e, value) =>
        act('PRG_changename', {
          new_name: value,
        })
      }
    />
    {!!can_admin && (
      <Button
        fluid
        bold
        content={'ADMIN MODE: ' + (adminmode ? 'ON' : 'OFF')}
        color={adminmode ? 'bad' : 'good'}
        onClick={() => act('PRG_toggleadmin')}
      />
    )}
  </Section>
);

const MessageSection = ({ in_channel, authorized, messages, title, this_client, act, PC_device_theme }) => (
  <Stack.Item grow={4}>
    <Stack vertical fill>
      <Stack.Item grow>
        <Section scrollable fill>
          {(in_channel &&
            (authorized ? (
              messages.map((message) => <Box key={message.msg}>{message.msg}</Box>)
            ) : (
              <Box textAlign="center">
                <Icon name="exclamation-triangle" mt={4} fontSize="40px" />
                <Box mt={1} bold fontSize="18px">
                  THIS CHANNEL IS PASSWORD PROTECTED
                </Box>
                <Box mt={1}>INPUT PASSWORD TO ACCESS</Box>
              </Box>
            ))) ||
            (PC_device_theme !== 'thinktronic-classic' && <NoChannelDimmer />)}
        </Section>
      </Stack.Item>
      {!!in_channel && (
        <Input
          backgroundColor={this_client && this_client.muted && 'red'}
          height="22px"
          placeholder={(this_client && this_client.muted && 'You are muted!') || 'Message ' + title}
          fluid
          selfClear
          mt={1}
          onEnter={(e, value) =>
            act('PRG_speak', {
              message: value,
            })
          }
        />
      )}
    </Stack>
  </Stack.Item>
);

const ClientList = ({
  displayed_clients,
  this_client,
  is_operator,
  act,
  client_color,
  in_channel,
  authorized,
  authed,
  strong,
}) => (
  <Stack.Item grow={2}>
    <Stack vertical fill>
      <Stack.Item grow>
        <Section scrollable fill>
          <Stack vertical>
            {displayed_clients.map((client) => (
              <Stack height="18px" fill key={client.name}>
                <Stack.Item basis={0} grow>
                  <Box inline color={client_color(client)}>
                    ⚫
                  </Box>{' '}
                  <Box inline bold={client.operator} color={client.operator ? 'yellow' : 'white'}>
                    {client.name}
                  </Box>
                </Stack.Item>
                {client !== this_client && (
                  <>
                    <Stack.Item>
                      <Button
                        disabled={this_client?.muted}
                        compact
                        icon="bullhorn"
                        tooltip={(!this_client?.muted && 'Ping') || 'You are muted!'}
                        tooltipPosition="left"
                        onClick={() =>
                          act('PRG_ping_user', {
                            ref: client.ref,
                          })
                        }
                      />
                    </Stack.Item>
                    {!!is_operator && (
                      <Stack.Item>
                        <Button
                          compact
                          icon={(!client.muted && 'volume-up') || 'volume-mute'}
                          color={(!client.muted && 'green') || 'red'}
                          tooltip={(!client.muted && 'Mute this User') || 'Unmute this User'}
                          tooltipPosition="left"
                          onClick={() =>
                            act('PRG_mute_user', {
                              ref: client.ref,
                            })
                          }
                        />
                      </Stack.Item>
                    )}
                  </>
                )}
              </Stack>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
      <Section title="Settings">
        <Stack.Item>
          {!!(in_channel && authorized) && (
            <>
              <Button.Input
                fluid
                content="Save log..."
                defaultValue="new_log"
                onCommit={(e, value) =>
                  act('PRG_savelog', {
                    log_name: value,
                  })
                }
              />
              <Button.Confirm fluid content="Leave Channel" onClick={() => act('PRG_leavechannel')} />
            </>
          )}
          {!!(is_operator && authed) && (
            <>
              <Button.Confirm fluid disabled={strong} content="Delete Channel" onClick={() => act('PRG_deletechannel')} />
              <Button.Input
                fluid
                disabled={strong}
                content="Rename Channel..."
                onCommit={(e, value) =>
                  act('PRG_renamechannel', {
                    new_name: value,
                  })
                }
              />
              <Button.Input
                fluid
                content="Set Password..."
                onCommit={(e, value) =>
                  act('PRG_setpassword', {
                    new_password: value,
                  })
                }
              />
            </>
          )}
        </Stack.Item>
      </Section>
    </Stack>
  </Stack.Item>
);

export const NtosNetChat = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    title,
    can_admin,
    adminmode,
    authed,
    username,
    active_channel,
    is_operator,
    strong,
    selfref,
    all_channels = [],
    clients = [],
    messages = [],
    PC_device_theme,
  } = data;

  const in_channel = active_channel !== null;
  const authorized = authed || adminmode;

  // this list has cliented ordered from their status. online > away > offline
  const displayed_clients = clients.sort((clientA, clientB) => {
    if (clientA.operator) {
      return -1;
    }
    if (clientB.operator) {
      return 1;
    }
    return clientB.status - clientA.status;
  });
  const client_color = (client) => {
    switch (client.status) {
      case CLIENT_ONLINE:
        return 'green';
      case CLIENT_AWAY:
        return 'yellow';
      case CLIENT_OFFLINE:
        return 'red';
      default:
        return 'label';
    }
  };
  // client from this computer!
  const this_client = clients.find((client) => client.ref === selfref);

  return (
    <NtosWindow width={1000} height={675}>
      <NtosWindow.Content>
        <Stack fill>
          <Flex fill grow={1} direction="column">
            <Flex.Item fill>
              <ChannelList all_channels={all_channels} active_channel={active_channel} act={act} />
            </Flex.Item>
            <Flex.Item>
              <UsernameSection username={username} can_admin={can_admin} adminmode={adminmode} act={act} />
            </Flex.Item>
          </Flex>
          <Stack.Divider />
          <MessageSection
            in_channel={in_channel}
            authorized={authorized}
            messages={messages}
            title={title}
            this_client={this_client}
            act={act}
            PC_device_theme={PC_device_theme}
          />
          {!!in_channel && (
            <>
              <Stack.Divider />
              <ClientList
                displayed_clients={displayed_clients}
                this_client={this_client}
                is_operator={is_operator}
                act={act}
                client_color={client_color}
                in_channel={in_channel}
                authorized={authorized}
                authed={authed}
                strong={strong}
              />
            </>
          )}
        </Stack>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
