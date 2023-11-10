import { classes } from 'common/react';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type ToolSelectionData = {
  selections: any[];
};

export const ToolSelection = (props, context) => {
  const { act, data } = useBackend<ToolSelectionData>(context);

  return (
    <Window width={380} height={550}>
      <Window.Content scrollable>
        <DisplayToolSelections />
      </Window.Content>
    </Window>
  );
};

const DisplayToolSelections = (props, context) => {
  const { act, data } = useBackend<ToolSelectionData>(context);
  const { selections } = data;
  const [current_selection, setSelection] = useSharedState(context, 'tab', selections[Object.keys(selections)[0]][0]);

  return Object.entries(selections).map(([category, options]) => {
    return (
      <Section key={category} title={category}>
        <Stack wrap>
          {options.map((each: string) => {
            return (
              <Stack.Item key={each}>
                <Button
                  mb={1}
                  key={each}
                  disabled={current_selection === each}
                  onClick={(e) => {
                    setSelection(each);
                    act('change_selection', { 'chosen_selection': each, 'chosen_category': category });
                  }}>
                  <Box className={classes(['tools32x32', each])} />
                  {each}
                </Button>
              </Stack.Item>
            );
          })}
        </Stack>
      </Section>
    );
  });
};
