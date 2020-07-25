import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';

export const MedipenFactory = props => {
  const { act, data } = useBackend(props);
  const {
    pen_size,
    pen_name,
    pen_style,
    pen_styles = [],
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Pen Volume">
          <NumberInput
            value={pen_size}
            unit="u"
            width="43px"
            minValue={5}
            maxValue={50}
            step={1}
            stepPixelSize={2}
            onChange={(e, value) => act('change_pen_size', {
              volume: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="pen Name">
          <Button
            icon="pencil-alt"
            content={pen_name}
            onClick={() => act('change_pen_name')} />
        </LabeledList.Item>
        <LabeledList.Item label="pen Style">
          {pen_styles.map(pen => (
            <Button
              key={pen.id}
              width={5}
              selected={pen.id === pen_style}
              textAlign="center"
              color="transparent"
              onClick={() => act('change_pen_style', {
                id: pen.id,
              })}>
              <Box mx={-1} className={pen.class_name} />
            </Button>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
