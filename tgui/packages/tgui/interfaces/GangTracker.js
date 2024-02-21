import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const GangTracker = (props, context) => {
  const { act, data } = useBackend(context);
  const { gangs = [] } = data;
  return (
    <Window theme="neutral" width={500} height={460}>
      <Window.Content scrollable>
        {gangs.map((gang) => (
          <Section
            key={gang.name}
            title={gang.name}>
            <LabeledList key={gang.gang}>
              <LabeledList.Item>Members: {gang.size}</LabeledList.Item>
              <LabeledList.Item>Territories: {gang.territories}</LabeledList.Item>
              <LabeledList.Item>Influence: {gang.influence}</LabeledList.Item>
              <LabeledList.Item>Reputation: {gang.reputation}</LabeledList.Item>
              <LabeledList.Item>Credits: {gang.credits}</LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
