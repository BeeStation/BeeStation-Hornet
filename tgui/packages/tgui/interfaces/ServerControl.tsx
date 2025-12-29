import { toFixed } from 'common/math';
import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  server_connected: BooleanLike;
  servers: ServerData[];
  consoles: ConsoleData[];
  logs: LogData[];
};

type ServerData = {
  server_name: string;
  server_details: string;
  server_enabled: BooleanLike;
  server_efficiency: number;
  server_temperature: number;
  server_temperature_warning: number;
  server_temperature_overheat: number;
  server_ref: string;
};

type ConsoleData = {
  console_name: string;
  console_location: string;
  console_locked: string;
  console_ref: string;
};

type LogData = {
  node_name: string;
  node_cost: string;
  node_researcher: string;
  node_research_location: string;
};

export const ServerControl = (props) => {
  const { data } = useBackend<Data>();
  const { server_connected } = data;

  return (
    <Window width={625} height={700}>
      <Window.Content scrollable={!!server_connected}>
        {server_connected ? (
          <>
            <ServersList />
            <ConsolesList />
            <ResearchHistory />
          </>
        ) : (
          <NoticeBox textAlign="center" danger>
            No techweb detected!
            <br /> <br />
            Sync a research server to this console with a multitool.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};

const ServersList = () => {
  const { act, data } = useBackend<Data>();
  const { servers } = data;

  const [show_servers, set_show_servers] = useState(true);

  return (
    <Section
      title="Research Servers"
      buttons={
        <Button
          icon={show_servers ? 'chevron-down' : 'chevron-up'}
          onClick={() => set_show_servers(!show_servers)}
        />
      }
    >
      {!servers ? (
        <NoticeBox info>No servers found.</NoticeBox>
      ) : (
        show_servers && (
          <Stack wrap>
            {servers.map((server) => {
              const efficiency_color =
                server.server_efficiency > 0.8
                  ? 'good'
                  : server.server_efficiency > 0.5
                    ? 'average'
                    : 'bad';

              const temperature_color =
                server.server_temperature < server.server_temperature_warning
                  ? 'good'
                  : server.server_temperature <
                      server.server_temperature_overheat
                    ? 'average'
                    : 'bad';

              return (
                <Stack.Item
                  key={server.server_ref}
                  width="32%"
                  style={{ border: '1px solid #000000' }}
                  p={1}
                >
                  <Box
                    color="label"
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}
                  >
                    {server.server_name}{' '}
                    <Button
                      icon={server.server_enabled ? 'sync-alt' : 'times'}
                      color={server.server_enabled ? 'good' : 'bad'}
                      fluid
                      textAlign="center"
                      mx={1}
                      onClick={() =>
                        act('toggle_server', {
                          selected_server: server.server_ref,
                        })
                      }
                    >
                      {server.server_enabled ? 'Online' : 'Offline'}
                    </Button>
                  </Box>
                  <LabeledList.Item label="Status" verticalAlign="middle">
                    <Box
                      color={
                        server.server_details === 'Nominal' ? 'good' : 'bad'
                      }
                    >
                      {server.server_details}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Efficiency" verticalAlign="middle">
                    <Box color={efficiency_color}>
                      <AnimatedNumber
                        value={parseFloat(
                          toFixed(server.server_efficiency * 100),
                        )}
                      />
                      {' %'}
                    </Box>
                  </LabeledList.Item>
                  <LabeledList.Item label="Temperature" verticalAlign="middle">
                    <Box color={temperature_color}>
                      <AnimatedNumber
                        value={parseFloat(toFixed(server.server_temperature))}
                      />
                      {' K'}
                    </Box>
                  </LabeledList.Item>
                </Stack.Item>
              );
            })}
          </Stack>
        )
      )}
    </Section>
  );
};

const ConsolesList = () => {
  const { act, data } = useBackend<Data>();
  const { consoles } = data;

  const [show_consoles, set_show_consoles] = useState(true);

  return (
    <Section
      title="Research Consoles"
      buttons={
        <Button
          icon={show_consoles ? 'chevron-down' : 'chevron-up'}
          onClick={() => set_show_consoles(!show_consoles)}
        />
      }
    >
      {!consoles ? (
        <NoticeBox info>No consoles found.</NoticeBox>
      ) : (
        show_consoles && (
          <Stack wrap justify="space-evenly">
            {consoles.map((console) => (
              <Stack.Item
                key={console.console_ref}
                style={{ border: '1px solid #000000' }}
                width="48%"
                p={1}
              >
                {console.console_name}
                <LabeledList.Item label="Location" verticalAlign="middle">
                  {console.console_location}
                </LabeledList.Item>
                <LabeledList.Item label="Status" verticalAlign="middle">
                  <Button
                    color={console.console_locked ? 'bad' : 'good'}
                    icon={console.console_locked ? 'lock' : 'unlock'}
                    fluid
                    textAlign="center"
                    onClick={() =>
                      act('lock_console', {
                        selected_console: console.console_ref,
                      })
                    }
                  >
                    {console.console_locked ? 'Locked' : 'Unlocked'}
                  </Button>
                </LabeledList.Item>
              </Stack.Item>
            ))}
          </Stack>
        )
      )}
    </Section>
  );
};

const ResearchHistory = () => {
  const { data } = useBackend<Data>();
  const { logs } = data;

  const [show_logs, set_show_logs] = useState(true);

  return (
    <Section
      title="Research History"
      buttons={
        <Button
          icon={show_logs ? 'chevron-down' : 'chevron-up'}
          onClick={() => set_show_logs(!show_logs)}
        />
      }
    >
      {!logs.length ? (
        <NoticeBox info>No history found.</NoticeBox>
      ) : (
        show_logs && (
          <Table>
            <Table.Row header>
              <Table.Cell>#</Table.Cell>
              <Table.Cell>Techweb Node</Table.Cell>
              <Table.Cell>Cost</Table.Cell>
              <Table.Cell>Researcher</Table.Cell>
              <Table.Cell>Location</Table.Cell>
            </Table.Row>
            {logs.map((server_log, index) => (
              <Table.Row
                mt={1}
                key={server_log.node_name}
                className="candystripe"
              >
                <Table.Cell>{index + 1}</Table.Cell>
                <Table.Cell>{server_log.node_name}</Table.Cell>
                <Table.Cell>{server_log.node_cost}</Table.Cell>
                <Table.Cell>{server_log.node_researcher}</Table.Cell>
                <Table.Cell>{server_log.node_research_location}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )
      )}
    </Section>
  );
};
