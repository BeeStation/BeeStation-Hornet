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

const NoChannelDimmer = (props) => {
  const { act, data } = useBackend();
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

export const NtosNetChat = (props) => {
  const { act, data } = useBackend();

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
