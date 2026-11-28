import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivePrintout } from './common/Objectives';

type Info = {
  antag_name: string;
  briefing: string[];
  objectives: Objective[];
};

export const AntagInfoBorer = (_props) => {
  const { data } = useBackend<Info>();
  const { antag_name, briefing, objectives } = data;
  return (
    <Window width={720} height={700} theme="neutral">
      <Window.Content scrollable>
        <Stack vertical>
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
          <Stack.Item>
            <Section title="Objectives">
              <ObjectivePrintout objectives={objectives} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
