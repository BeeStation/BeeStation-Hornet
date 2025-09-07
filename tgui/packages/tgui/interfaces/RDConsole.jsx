import { toFixed } from 'common/math';

import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

const RDServerStatus = (props) => {
  const { act, data } = useBackend();
  const { value, ...rest } = props;
  const {
    name,
    server_id,
    temperature,
    temperature_warning,
    temperature_max,
    enabled,
    overheated,
  } = value;
  const tempState =
    (temperature < temperature_warning && 'good') ||
    (temperature > temperature_warning &&
      temperature < temperature_max &&
      'average') ||
    'bad';
  const overheadedState =
    (overheated && 'Halted') ||
    (temperature > temperature_warning &&
      temperature < temperature_max &&
      'Warning') ||
    'Normal';
  return (
    <Box {...rest} width="170px" style={{ border: '1px solid #000000' }}>
      <Flex mx={0.5} my={0.5} direction="row" justify="space-around">
        <Flex direction="column" align="auto">
          <Flex.Item color="label">{name}</Flex.Item>
          <Flex.Item>
            <Flex direction="row" justify="space-between">
              <Flex.Item textAlign="left" align="left" color={tempState}>
                {overheadedState}
              </Flex.Item>
              <Flex.Item textAlign="right" align="right" color={tempState}>
                <AnimatedNumber value={toFixed(temperature)} /> K
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
        <Flex.Item align="center">
          <Button
            icon={enabled ? 'sync-alt' : 'times'}
            selected={enabled}
            onClick={() => act('enable_server', { server_id: server_id })}
          >
            {enabled ? 'On' : 'Off'}
          </Button>
        </Flex.Item>
      </Flex>
    </Box>
  );
};

const RDServerLogItem = (props) => {
  const { act, data } = useBackend();
  const { value, ...rest } = props;
  const {
    entry = '',
    research_name = '',
    cost = '',
    researcher_name = '',
    location = '',
  } = value;
  return (
    <Flex {...rest} align="baseline" justify="space-between">
      <Flex.Item width={3}>{entry}</Flex.Item>
      <Flex.Item width={20}>{research_name}</Flex.Item>
      <Flex.Item width={10}>{cost}</Flex.Item>
      <Flex.Item width={20}>{researcher_name}</Flex.Item>
      <Flex.Item width={20}>{location}</Flex.Item>
    </Flex>
  );
};

export const RDConsole = (props) => {
  const { act, data } = useBackend();
  const { logs = [], servers = [] } = data;
  return (
    <Window width={900} height={750}>
      <Window.Content scrollable>
        <Section title="Servers">
          {servers.map((server) => (
            <RDServerStatus key={server.name} value={server} />
          ))}
        </Section>
        <Section title="Access Logs">
          <Flex direction="column">
            <RDServerLogItem
              color="label"
              value={{
                researcher_name: 'Researcher',
                research_name: 'Technology',
                cost: 'Cost',
                location: 'Location',
              }}
            />
            {logs.map((entry) => (
              <RDServerLogItem key={entry.entry} value={entry} />
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
