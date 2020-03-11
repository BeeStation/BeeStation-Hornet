import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';

export const BottleDispenser = props => {
  const { act, data } = useBackend(props);
  const {
    bottle_size,
    bottle_name,
  } = data;
  return (
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
  );
};
