import { useBackend } from '../backend';
import { Chart, Input, Section, Stack, ProgressBar, Button, Flex, Divider } from '../components';
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

export const Telemonitor = (props) => {
  const { act, data } = useBackend<Tdata>();
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
              <span className="loading-one">.</span>
              <span className="loading-two">.</span>
              <span className="loading-three">.</span>
            </Flex.Item>
          </Flex>
        ) : (
          <Flex>
            <Flex.Item>
              <ServerList />
            </Flex.Item>
            <Flex.Item grow={1}>
              <ServerDetails />
            </Flex.Item>
          </Flex>
        )}
      </Window.Content>
    </Window>
  );
};

const ServerList = (props) => {
  const { act, data } = useBackend<Tdata>();
  const isOnline = function (server) {
    return Math.floor((data.current_time - server.last_update) / 10) < 10;
  };
  return (
    <Section title="Servers">
      {Object.values(data.servers).map((server) => {
        const efficiencyColor = `#${Math.round((1 - server.efficiency) * 200 + 55)
          .toString(16)
          .padStart(2, '0')}${Math.round(server.efficiency * 200 + 55)
          .toString(16)
          .padStart(2, '0')}55`;
        return (
          <Section
            m={1}
            key={server.sender_id}
            title={server.name}
            titleColor={efficiencyColor}
            buttons={<Button>select</Button>}>
            {server.temperatures[server.temperatures.length - 1]}
          </Section>
        );
      })}
    </Section>
  );
};

const ServerDetails = (props) => {
  const { act, data } = useBackend<Tdata>();
  const server: server = Object.values(data.servers)[0];
  const temperatureData = server.temperatures.map((value, i) => [i, value]);

  return (
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
  );
};
