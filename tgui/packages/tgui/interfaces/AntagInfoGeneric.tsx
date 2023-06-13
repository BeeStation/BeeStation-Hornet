import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  objectives: Objective[];
};

const IntroSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { antag_name } = data;
  return (
    <Section>
      <h1 style={{ 'position': 'relative', 'top': '25%', 'left': '25%' }}>
        You are the{' '}
        <Box inline textColor="bad">
          {antag_name || 'Antagonist'}
        </Box>
        !
      </h1>
    </Section>
  );
};

export const AntagInfoGeneric = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Window width={620} height={250} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <IntroSection />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
