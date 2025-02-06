import { capitalizeAll } from 'common/string';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Section, Stack } from 'tgui/components';
import { Window } from 'tgui/layouts';

type SpawnersMenuContext = {
  spawners: spawner[];
};

type spawner = {
  name: string;
  amount_left: number;
  desc?: string;
  you_are_text?: string;
  flavor_text?: string;
  important_text?: string;
};

export const SpawnersMenu = (props) => {
  const { act, data } = useBackend<SpawnersMenuContext>();
  const spawners = data.spawners || [];
  return (
    <Window title="Spawners Menu" width={700} height={525}>
      <Window.Content scrollable>
        <Stack vertical>
          {spawners.map((spawner) => (
            <Stack.Item key={spawner.name}>
              <Section
                fill
                // Capitalizes the spawner name
                title={capitalizeAll(spawner.name)}
                buttons={
                  <Stack>
                    <Stack.Item fontSize="14px" color="green">
                      {spawner.amount_left} left
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="Jump"
                        onClick={() =>
                          act('jump', {
                            name: spawner.name,
                          })
                        }
                      />
                      <Button
                        content="Spawn"
                        onClick={() =>
                          act('spawn', {
                            name: spawner.name,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                }>
                <LabeledList>
                  {spawner.desc ? (
                    <LabeledList.Item label="Description">{spawner.desc}</LabeledList.Item>
                  ) : (
                    <div>
                      <LabeledList.Item label="Origin">{spawner.you_are_text || 'Unknown'}</LabeledList.Item>
                      <LabeledList.Item label="Directives">{spawner.flavor_text || 'None'}</LabeledList.Item>
                      <LabeledList.Item color="bad" label="Conditions">
                        {spawner.important_text || 'None'}
                      </LabeledList.Item>
                    </div>
                  )}
                </LabeledList>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
