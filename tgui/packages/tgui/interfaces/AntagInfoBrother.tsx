import { useBackend } from '../backend';
import { Stack } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  antag_name: string;
  objectives: Objective[];
  brothers: string;
};
export const AntagInfoBrother = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives, antag_name, brothers } = data;
  return (
    <Window width={620} height={250} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={`${antag_name || 'Blood Brother'} of ${brothers}`} asset="traitor.png" />
          </Stack.Item>
          <Stack.Item grow>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
