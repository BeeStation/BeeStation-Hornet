import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const PsychicPlane = (props, context) => {
  const { act, data } = useBackend(context);
  const { hives = [] } = data;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        {hives.map((hive) => (
          <Section
            key={hive.hive}
            title={'Hive ' + hive.hive}
            buttons={
              <Button
                icon="brain"
                content="Track"
                color="good"
                onClick={() =>
                  act('track', {
                    hiveref: hive.hive,
                  })
                }
              />
            }>
            <LabeledList key={hive.hive}>
              <LabeledList.Item>{hive.type}</LabeledList.Item>
              <LabeledList.Item>Vessel Amount: {hive.size}</LabeledList.Item>
              <LabeledList.Item>Charges: {hive.charges}</LabeledList.Item>
              <LabeledList.Item>Integrations: {hive.Integrations}</LabeledList.Item>
              <LabeledList.Item>Awakened Vessels: {hive.avessel_number}</LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
