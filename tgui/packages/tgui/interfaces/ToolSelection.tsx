import { classes } from 'common/react';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

type ToolSelectionData = {
  selections: string[];
};

export const ToolSelection = (props, context) => {
  const { act, data } = useBackend<ToolSelectionData>(context);

  return (
    <Window width={350} height={400}>
      <Window.Content>
        <Section fill title="Tool selection">
          <DisplayToolSelections />
        </Section>
      </Window.Content>
    </Window>
  );
};

const DisplayToolSelections = (props, context) => {
  const { act, data } = useBackend<ToolSelectionData>(context);
  const { selections } = data;
  const [current_selection, setSelection] = useSharedState(context, 'tab', selections[0]);

  return (
    <Stack wrap>
      {selections.map((each) => {
        return (
          <Stack.Item key={each}>
            <Button
              mb={1}
              key={each}
              disabled={current_selection === each}
              onClick={(e) => {
                setSelection(each);
                act('change_selection', { 'chosen_selection': each });
              }}>
              <Box className={classes(['tools32x32', each])} />
              {each}
            </Button>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};
