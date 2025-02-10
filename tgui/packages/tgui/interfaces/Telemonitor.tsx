import { useBackend } from '../backend';
import { Chart, Input, Section, Stack, ProgressBar, Button, Flex } from '../components';
import { Window } from '../layouts';
type Tdata = {
  network_id: string;
  current_time: number; // world.time during ui_update
  servers: server[]; // list of servers
};
type server = {
  name: string; // name of the server
  sender_id: string; // hardware id of the server
  temperatures: Array<number>; // Kelvins
  overheat_temperature: number; // Kelvins
  efficiency: number; // 0-1 range
  last_update: number; // world.time of last update
  overheated: boolean; // true/false
};
export const Telemonitor = (props, context) => {
  const { act, data } = useBackend<Tdata>(context);
  const isOnline = function (server) {
    return Math.floor((data.current_time - server.last_update) / 10) < 10;
  };
  return (
    <Window width={1000} height={850}>
      <Window.Content scrollable>
        <Section title="Server panel">
          Network to monitor:
          <br />
          <Input
            value={data.network_id}
            placeholder={`network id`}
            width="100%"
            onChange={(e, value) =>
              act('change_network', {
                network_name: value,
              })
            }
          />
        </Section>
        {data.servers.length === 0 ? (
          <Flex direction="column" align="center" fontSize="15px">
            <Flex.Item fontSize="20px">
              Searching for servers
              <span class="loading-one">.</span>
              <span class="loading-two">.</span>
              <span class="loading-three">.</span>
            </Flex.Item>
          </Flex>
        ) : (
          <Stack fill wrap="wrap" justify="space-evenly">
            {Object.values(data.servers).map((server) => {
              const temperatureData = server.temperatures.map((value, i) => [i, value]);
              return (
                <Stack.Item m={1} width="32%" key={server.name}>
                  <Section
                    title={`${server.name} (${server.sender_id})`}
                    buttons={
                      <Button
                        color={isOnline(server) && !server.overheated ? 'good' : 'bad'}
                        tooltip={`${Math.floor((data.current_time - server.last_update) / 10)}s since last update`}>
                        {isOnline(server) ? (server.overheated ? 'OVERHEATED' : 'ONLINE') : 'OFFLINE'}
                      </Button>
                    }>
                    Efficiency:{' '}
                    <ProgressBar
                      ranges={{
                        good: [0.6, Infinity],
                        average: [0.4, 0.6],
                        bad: [-Infinity, 0.4],
                      }}
                      value={isOnline(server) ? server.efficiency : 0}
                    />
                    Temperature: {Math.round(server.temperatures[server.temperatures.length - 1])}K
                    <Section height="200px">
                      <Chart.Line
                        height="200px"
                        data={temperatureData}
                        rangeX={[0, temperatureData.length]}
                        rangeY={[0, server.overheat_temperature]}
                        strokeColor="rgb(255, 255, 255)"
                        fillColor="rgba(10, 1, 1, 1)"
                      />
                    </Section>
                  </Section>
                </Stack.Item>
              );
            })}
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};
