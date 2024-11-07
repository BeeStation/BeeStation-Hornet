import { classes } from 'common/react';
import { useBackend, useSharedState } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

type ToolSelectionData = {
  selections: any[];
};

export const ToolSelection = (props, context) => {
  const { act, data } = useBackend<ToolSelectionData>(context);

  return (
    <Window width={350} height={530}>
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
        <Flex wrap>
          {options.map((each: string) => {
            return (
              <Flex.Item m={0.1} p={0.1} key={each}>
                <Button
                  key={each}
                  disabled={current_selection === each}
                  onClick={(e) => {
                    setSelection(each);
                    act('change_selection', { 'chosen_selection': each, 'chosen_category': category });
                  }}>
                  <Flex>
                    <Flex.Item m={-0.5}>
                      <Box className={classes(['tools32x32', each])} />
                    </Flex.Item>
                    <Flex.Item pl={1} align="center">
                      {each}
                    </Flex.Item>
                  </Flex>
                </Button>
              </Flex.Item>
            );
          })}
        </Flex>
      </Section>
    );
  });
};
