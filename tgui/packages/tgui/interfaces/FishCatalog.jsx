import { sortBy } from 'common/collections';
import { classes } from 'common/react';
import { capitalize } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

export const FishCatalog = (props) => {
  const { act, data } = useBackend();
  const { fish_info, sponsored_by } = data;
  const fish_by_name = sortBy(fish_info || [], (fish) => fish.name);
  const [currentFish, setCurrentFish] = useLocalState('currentFish', null);
  return (
    <Window theme="generic" width={500} height={300} resizable>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="120px">
            <Section fill scrollable>
              {fish_by_name.map((f) => (
                <Button
                  key={f.name}
                  fluid
                  color="transparent"
                  selected={f === currentFish}
                  onClick={() => {
                    setCurrentFish(f);
                  }}
                >
                  {f.name}
                </Button>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Section
              fill
              scrollable
              title={
                currentFish
                  ? capitalize(currentFish.name)
                  : sponsored_by + ' Fish Index'
              }
            >
              {currentFish && (
                <LabeledList>
                  <LabeledList.Item label="Description">
                    {currentFish.desc}
                  </LabeledList.Item>
                  <LabeledList.Item label="Water type">
                    {currentFish.fluid}
                  </LabeledList.Item>
                  <LabeledList.Item label="Temperature">
                    {currentFish.temp_min} to {currentFish.temp_max}
                  </LabeledList.Item>
                  <LabeledList.Item label="Feeding">
                    {currentFish.feed}
                  </LabeledList.Item>
                  <LabeledList.Item label="Acquisition">
                    {currentFish.source}
                  </LabeledList.Item>
                  <LabeledList.Item label="Illustration">
                    <Box className={classes(['fish32x32', currentFish.icon])} />
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
