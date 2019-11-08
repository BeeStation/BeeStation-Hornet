import { act } from '../byond';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { getGasLabel } from './common/atmos';

export const AtmosFilter = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const filterTypes = data.filter_types || [];
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            onClick={() => act(ref, 'power')} />
        </LabeledList.Item>
        <LabeledList.Item label="Transfer Rate">
          <NumberInput
            animated
            value={parseFloat(data.rate)}
            width="63px"
            unit="L/s"
            minValue={0}
            maxValue={200}
            onDrag={(e, value) => act(ref, 'rate', {
              rate: value,
            })} />
          <Button
            ml={1}
            icon="plus"
            content="Max"
            disabled={data.rate === data.max_rate}
            onClick={() => act(ref, 'rate', {
              rate: 'max',
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Filter">
          {filterTypes.map(filter => (
            <Button
              key={filter.id}
              selected={filter.selected}
              content={getGasLabel(filter.id, filter.name)}
              onClick={() => act(ref, 'filter', {
                mode: filter.id,
              })} />
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
