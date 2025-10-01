import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, NumberInput } from 'tgui-core/components';

import type { AirAlarmData } from '../types';

export function AirAlarmAirConditioningControls(props) {
  const {
    act,
    data: {
      ac: { enabled, target, min, max },
    },
  } = useBackend<AirAlarmData>();
  return (
    <>
      <Button
        icon="fire"
        color={enabled && 'good'}
        onClick={() => act('air_conditioning', { value: !!enabled })}
      >
        Toggle Air Conditioning
      </Button>
      <Box mt={1} />
      <LabeledList>
        <LabeledList.Item label={'Target Temperature'}>
          <NumberInput
            value={target}
            minValue={min}
            maxValue={max}
            step={1}
            onChange={(value: number) => act('set_ac_target', { value })}
            unit="K"
            disabled={!enabled}
          />
          <Button
            icon="thermometer-quarter"
            content="Default"
            color={enabled && 'good'}
            onClick={() => act('default_ac_target')}
          />
        </LabeledList.Item>
      </LabeledList>
    </>
  );
}
