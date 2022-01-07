import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Tabs, ProgressBar, Section, Flex, Icon, NoticeBox } from '../components';
import { Window } from '../layouts';

export const AiServerConsole = (props, context) => {
  const { act, data } = useBackend(context);

  const { username, has_access } = data;

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  return (
    <Window
      width={500}
      height={450}
      resizable>
      <Window.Content scrollable>
        <Section title="Server Overview">
          {data.servers.map((server, index) => {
            return (
              <Section key={index}>
                <Box textAlign="center">Location: <Box inline bold>{server.area}</Box></Box>
                <Box textAlign="center" bold>Status: <Box inline color={server.working ? "good" : "bad"}>{server.working ? "ONLINE" : "OFFLINE"}</Box></Box>
                <ProgressBar
                  ranges={{
                    good: [-Infinity, 250],
                    average: [250, 750],
                    bad: [750, Infinity],
                  }}
                  value={server.temp}
                  maxValue={750}>{server.temp}K
                </ProgressBar>
                <Box textAlign="center">Capacity: <Box inline bold>{server.card_capacity} cards</Box></Box>
                <Box textAlign="center">CPU Power: <Box inline bold>{server.total_cpu} THz</Box></Box>
                <Box textAlign="center">RAM Capacity: <Box inline bold>{server.ram} TB</Box></Box>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
