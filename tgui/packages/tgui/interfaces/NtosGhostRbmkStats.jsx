// NSV13

import { Button, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';

export const NtosGhostRbmkStats = (props) => {
  const { act, data } = useBackend();
  return (
    <NtosWindow resizable width={440} height={650}>
      <NtosWindow.Content>
        <Section
          title="Legend:"
          buttons={<Button icon="search" onClick={() => act('swap_reactor')} content="Change Reactor" />}>
          Reactor Integrity (%):
          <ProgressBar value={data.integrity} minValue={0} maxValue={100} color="orange" />
          Reactor Power (%):
          <ProgressBar value={data.power} minValue={0} maxValue={100} color="yellow" />
          Reactor Pressure (KPA):
          <ProgressBar value={data.kpa} minValue={0} maxValue={8200} color="white">
            {data.kpa} KPA
          </ProgressBar>
          Coolant temperature (°C):
          <ProgressBar value={data.coolantInput} minValue={-273.15} maxValue={1227} color="blue">
            {data.coolantInput} °C
          </ProgressBar>
          Outlet temperature (°C):
          <ProgressBar value={data.coolantOutput} minValue={-273.15} maxValue={1227} color="bad">
            {data.coolantOutput} °C
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
