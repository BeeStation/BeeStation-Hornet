import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Evolution = {
  name: string;
  desc: string;
  helptext: string;
  path: string;
  cost: number;
  zone: string;
  owned: boolean;
  can_purchase: boolean;
};

type BorerEvolutionContext = {
  evolution_points: number;
  host_zone: string;
  evolutions: Evolution[];
};

export const BorerEvolution = () => {
  const { act, data } = useBackend<BorerEvolutionContext>();
  const { evolution_points, host_zone, evolutions } = data;
  return (
    <Window theme="neutral" width={900} height={480}>
      <Window.Content>
        <Section
          fill
          scrollable
          title="Evolution Points"
          buttons={
            <Stack>
              <Stack.Item fontSize="16px">
                {evolution_points} <Icon name="dna" color="#DD66DD" />
              </Stack.Item>
              <Stack.Item color="label">Host: {host_zone}</Stack.Item>
            </Stack>
          }
        >
          {!evolutions?.length ? (
            <NoticeBox>No evolutions available.</NoticeBox>
          ) : (
            <LabeledList>
              {evolutions.map((evolution) => (
                <LabeledList.Item
                  key={evolution.path}
                  className="candystripe"
                  label={evolution.name}
                  buttons={
                    <Stack>
                      <Stack.Item>{evolution.cost}</Stack.Item>
                      <Stack.Item>
                        <Icon
                          name="dna"
                          color={evolution.owned ? '#DD66DD' : 'gray'}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          content="Evolve"
                          disabled={evolution.owned || !evolution.can_purchase}
                          onClick={() =>
                            act('evolve', { path: evolution.path })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  }
                >
                  {evolution.desc}
                  <Box color="label">Requires: {evolution.zone}</Box>
                  <Box color="good">{evolution.helptext}</Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
