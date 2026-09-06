import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  briefing: string[];
  objectives: Objective[];
};

export const AntagInfoBorer = (_props) => {
  const { data } = useBackend<Info>();
  const { antag_name, briefing, objectives } = data;
  return (
    <Window width={620} height={480} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={antag_name || 'Cortical Borer'} />
          </Stack.Item>
          <Stack.Item>
            <Section title="Briefing">
              <Stack vertical>
                {briefing.map((paragraph) => (
                  <Stack.Item key={paragraph}>{paragraph}</Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
