import { useBackend } from '../backend';
import { Button, Divider, Box, Section } from '../components';
import { Window } from '../layouts';

export const Objective = (props, context) => {
  const { act, data } = useBackend(context);
  const { possible_objectives = [], selected_objective = null } = data;
  return (
    <Window width={400} height={500} resizable>
      <Window.Content scrollable>
        {!selected_objective || <SelectedObjective objective={selected_objective} />}
        {possible_objectives.map((objective) => (
          <Section title={objective.name} key={objective.id}>
            <Box mb={1}>Payout: {objective.payout}</Box>
            <Box mb={1}>{objective.description}</Box>
            <Button
              content="Accept"
              icon="check"
              onClick={(e) =>
                act('assign', {
                  'id': objective.id,
                })
              }
              disabled={selected_objective !== null}
            />
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};

export const SelectedObjective = (props, context) => {
  const { objective = [] } = props;
  return (
    <>
      <Section title={objective.name}>
        <Box>Payout: {objective.payout}</Box>
        <Box>{objective.description}</Box>
      </Section>
      <Divider />
    </>
  );
};
