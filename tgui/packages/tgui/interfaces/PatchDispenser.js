import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const PatchDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    patch_size,
    patch_name,
  } = data;
  return (
    <Window
      width={300}
      height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Patch Volume">
              <NumberInput
                value={patch_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={40}
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
      </Window.Content>
    </Window>
  );
};
