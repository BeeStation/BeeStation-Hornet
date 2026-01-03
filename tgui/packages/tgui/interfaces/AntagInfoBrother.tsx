import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};
export const AntagInfoBrother = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives, antag_name, brothers } = data;
  return (
    <Window width={620} height={250} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader
              name={`${antag_name || 'Blood Brother'} of ${brothers}`}
              asset="traitor.png"
            />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
