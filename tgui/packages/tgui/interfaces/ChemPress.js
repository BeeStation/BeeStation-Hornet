import { useBackend } from '../backend';
import { Box, Button, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const ChemPress = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    pill_size,
    pill_name,
    pill_style,
    pill_styles = [],
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Pill Volume">
              <NumberInput
                value={pill_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={50}
                step={1}
                stepPixelSize={2}
                onChange={(e, value) => act('change_pill_size', {
                  volume: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Pill Name">
              <Input
                value={pill_name}
                onChange={(e, value) => act('change_pill_name', {
                  name: value,
                })} />
            </LabeledList.Item>
            <LabeledList.Item label="Pill Style">
              {pill_styles.map(pill => (
                <Button
                  key={pill.id}
                  width="30px"
                  selected={pill.id === pill_style}
                  textAlign="center"
                  color="transparent"
                  onClick={() => act('change_pill_style', {
                    id: pill.id,
                  })}>
                  <Box mx={-1} className={pill.class_name} />
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
