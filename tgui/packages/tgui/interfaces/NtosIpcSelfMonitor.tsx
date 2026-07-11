import { useBackend } from '../backend';
import {
  Flex,
  ProgressBar,
  Section,
} from '../components';
import { NtosWindow } from '../layouts';

type Upgrade = {
  name: String
  power_req: number
  active_power_req: number
}

type Data = {
  name: String
  charge: number
  max_charge: number
  upgrade_core: Upgrade
  upgrade_external: Upgrade
  upgrade_utility: Upgrade
  control_circuit: Boolean
}

export const NtosIpcSelfMonitor = (_) => {
  const { data } = useBackend();
  return (
    <NtosWindow width={800} height={600}>
      <NtosWindow.Content>
        <NtosIpcSelfMonitorContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosIpcSelfMonitorContent = (_) => {
  const { act, data } = useBackend<Data>();
  return (
  <Flex direction={'row'}>
    <Section title="CORE.STAT">
      {data.name}
      <br />
      {data.charge}
      <ProgressBar
      value={data.max_charge ? data.charge / data.max_charge * 100 : 0}
      minValue={0}
      maxValue={100}
      ranges={{
        bad: [-Infinity, 25],
        average: [25, 75],
        good: [75, Infinity],
      }}
      />
    </Section>
  </Flex>);
};
