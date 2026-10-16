import { Button, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { getGasLabel } from '../constants';
import { Window } from '../layouts';
import { PortableBasicInfo } from './common/PortableAtmos';

type Data = {
  filter_types: Filter[];
};

type Filter = {
  id: string;
  enabled: BooleanLike;
  gas_id: string;
  gas_name: string;
};

export function PortableScrubber() {
  const { act, data } = useBackend<Data>();
  const { filter_types = [] } = data;

  return (
    <Window width={320} height={420}>
      <Window.Content>
        <PortableBasicInfo />
        <Section title="Filters">
          {filter_types.map((filter) => (
            <Button
              key={filter.id}
              icon={filter.enabled ? 'check-square-o' : 'square-o'}
              selected={filter.enabled}
              onClick={() =>
                act('toggle_filter', {
                  val: filter.gas_id,
                })
              }
            >
              {getGasLabel(filter.gas_id, filter.gas_name)}
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
}
