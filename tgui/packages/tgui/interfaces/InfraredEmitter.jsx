import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const InfraredEmitter = (props) => {
  const { act, data } = useBackend();
  const { on, visible } = data;
  return (
    <Window width={225} height={110}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'On' : 'Off'}
                selected={on}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Visibility">
              <Button
                icon={visible ? 'eye' : 'eye-slash'}
                content={visible ? 'Visible' : 'Invisible'}
                selected={visible}
                onClick={() => act('visibility')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
