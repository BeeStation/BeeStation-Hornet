import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';

export const PatchDispenser = props => {
  const { act, data } = useBackend(props);
  const {
    patch_size,
    patch_name,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Patch Volume">
          <NumberInput
            value={patch_size}
            unit="u"
            width="43px"
            minValue={5}
            maxValue={50}
            step={1}
            stepPixelSize={2}
            onChange={(e, value) => act('change_patch_size', {
              volume: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Patch Name">
          <Button
            icon="pencil-alt"
            content={patch_name}
            onClick={() => act('change_patch_name')} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
