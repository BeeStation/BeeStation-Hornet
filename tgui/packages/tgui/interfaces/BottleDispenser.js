import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const BottleDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    bottle_size,
    bottle_name,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Bottle Volume">
              <NumberInput
                value={bottle_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={30}
                step={1}
                stepPixelSize={2}
                onChange={(e, value) => act('change_bottle_size', {
                  volume: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Bottle Name">
              <Button
                icon="pencil-alt"
                content={bottle_name}
                onClick={() => act('change_bottle_name')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
