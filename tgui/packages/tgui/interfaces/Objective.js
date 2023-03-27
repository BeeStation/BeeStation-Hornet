import { useBackend } from '../backend';
import { Button, Divider, Box, Section } from '../components';
import { Window } from '../layouts';

export const Objective = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    possible_objectives = [],
  } = data;
  return (
    <Window
      width={400}
      height={500}
      resizable>
      <Window.Content
        scrollable>
        {possible_objectives.map(objective => (
          <Section
            title={objective.name}
            key={objective.id}>
            <Box mb={1}>
              Payout: {objective.payout}
            </Box>
            <Box mb={1}>
              {objective.description}
            </Box>
            <Button
              content="Accept"
              icon="check"
              onClick={e => act("assign", {
                "id": objective.id,
              })} />
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
