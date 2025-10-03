import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  objectives: Objective[];
};

export const AntagInfoGeneric = (_props) => {
  const { data } = useBackend<Info>();
  const { antag_name, objectives } = data;
  return (
    <Window width={620} height={250} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={antag_name || 'Antagonist'} />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
