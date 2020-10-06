import { round } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Dropdown, NumberInput } from '../components';
import { Window } from '../layouts';

export const MaterialDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    value1,
    allowed_mats,
    targetAmmount,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Dispenser">
          <LabeledList>
            <LabeledList.Item label="materials">
              <Dropdown
                selected={value1}
                options={allowed_mats}
                width="150px"
                onSelected={val => act('mat_type', {
                  type: val,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Ammount">
              <NumberInput
                width="65px"
                unit="U"
                step={1}
                stepPixelSize={3}
                value={round(targetAmmount)}
                minValue={1}
                maxValue={10}
                onDrag={(e, value) => act('ammount', {
                  target: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="On">
              <Button
                content="turn the dispenser on"
                onClick={() => act('on')} />
            </LabeledList.Item>
            <LabeledList.Item label="Off">
              <Button
                content="turn the dispenser off"
                onClick={() => act('off')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};