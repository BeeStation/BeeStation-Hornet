import { useBackend } from '../../backend';
import { Box, Button, Icon, LabeledList } from '../../components';

export const ReagentLookup = (props, context) => {
  const { reagent } = props;
  const { act } = useBackend(context);
  if (!reagent) {
    return (
      <Box>
        No reagent selected!
      </Box>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Reagent">
        <Icon name="circle" mr={1} color={reagent.reagentCol} />
        {reagent.name}
        <Button
          ml={1}
          icon="wifi"
          color="teal"
          tooltip="Open the associated wikipage for this reagent."
          tooltipPosition="left"
          onClick={() => {
            Byond.command(`wiki Guide_to_chemistry#${reagent.name}`);
          }} />
      </LabeledList.Item>
      <LabeledList.Item label="Description">
        {reagent.desc}
      </LabeledList.Item>
      <LabeledList.Item label="Properties">
        <LabeledList>
          {!!reagent.OD && (
            <LabeledList.Item label="Overdose">
              {reagent.OD}u
            </LabeledList.Item>
          )}
          {reagent.addictions[0] && (
            <LabeledList.Item label="Addiction">
              {reagent.addictions.map(addiction => (
                <Box key={addiction}>
                  {addiction}
                </Box>
              ))}
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Metabolization rate">
            {reagent.metaRate}u/s
          </LabeledList.Item>
        </LabeledList>
      </LabeledList.Item>
      <LabeledList.Item label="Special Properties">
        {reagent.deadProcess && (
          <Box>
            This reagent works on the dead.
          </Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          icon="flask"
          mt={2}
          content={"Find associated reaction"}
          color="purple"
          onClick={() => act('find_reagent_reaction', {
            id: reagent.id,
          })} />
      </LabeledList.Item>
    </LabeledList>
  );
};
