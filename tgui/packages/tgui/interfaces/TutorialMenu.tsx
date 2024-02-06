import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Divider, Button, Tabs } from '../components';
import { Window } from '../layouts';

type Tutorial = {
  name: string;
  path: string;
  id: string;
  description: string;
  image: string;
};

type TutorialCategory = {
  tutorials: Tutorial[];
  name: string;
};

type BackendContext = {
  tutorial_categories: TutorialCategory[];
  completed_tutorials: string[];
};

export const TutorialMenu = (props, context) => {
  const { data, act } = useBackend<BackendContext>(context);
  const { tutorial_categories, completed_tutorials } = data;
  const [chosenTutorial, setTutorial] = useLocalState<Tutorial | null>(context, 'tutorial', null);
  const [categoryIndex, setCategoryIndex] = useLocalState(context, 'category_index', 'Space Station 13');
  return (
    <Window title="Tutorial Menu" width={800} height={600} theme="usmc">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <span
              style={{
                'position': 'relative',
                'top': '0px',
              }}>
              <Tabs>
                {tutorial_categories.map((item, key) => (
                  <Tabs.Tab
                    key={item.name}
                    selected={item.name === categoryIndex}
                    onClick={() => {
                      setCategoryIndex(item.name);
                    }}>
                    {item.name}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </span>
          </Stack.Item>
          <Stack fill grow>
            <Stack.Item grow mr={1}>
              <Section fill height="100%">
                {tutorial_categories.map(
                  (tutorial_category) =>
                    tutorial_category.name === categoryIndex &&
                    tutorial_category.tutorials.map((tutorial) => (
                      <div style={{ 'padding-bottom': '12px' }} key={tutorial.id}>
                        <Button
                          fontSize="15px"
                          textAlign="center"
                          selected={tutorial === chosenTutorial}
                          width="100%"
                          key={tutorial.id}
                          onClick={() => setTutorial(tutorial)}>
                          {tutorial.name}
                        </Button>
                      </div>
                    ))
                )}
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item width="30%">
              <Section title="Selected Tutorial">
                {chosenTutorial !== null ? (
                  <Stack vertical>
                    <Stack.Item>
                      <div
                        style={{
                          'display': 'flex',
                          'justify-content': 'center',
                          'align-items': 'center',
                        }}>
                        <Box key={chosenTutorial.id}>
                          <span className={classes(['tutorial128x128', `${chosenTutorial.image}`])} />
                        </Box>
                      </div>
                    </Stack.Item>
                    <Stack.Item>{chosenTutorial.description}</Stack.Item>

                    <Stack.Item>
                      <Button
                        content="Start Tutorial"
                        textAlign="center"
                        width="100%"
                        onClick={() =>
                          act('select_tutorial', {
                            tutorial_path: chosenTutorial.path,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                ) : (
                  <div />
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};
