import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  antag_name: string;
  objectives: Objective[];
};

export const AntagInfoGeneric = (_props, context) => {
  const { data } = useBackend<Info>(context);
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
