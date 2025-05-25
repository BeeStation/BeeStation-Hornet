// NSV13

import { useBackend } from '../backend';
import { Button, ProgressBar, Section } from '../components';
import { NtosWindow } from '../layouts';

export const NtosGhostRbmkStats = (props) => {
  const { act, data } = useBackend();
  return (
    <NtosWindow resizable width={440} height={650}>
      <NtosWindow.Content>
        <Section
          title="Legend:"
          buttons={
            <Button
              icon="search"
              onClick={() => act('swap_reactor')}
              content="Change Reactor"
            />
          }
        >
          Reactor Integrity (%):
          <ProgressBar
            value={data.integrity}
            minValue={0}
            maxValue={100}
            color="orange"
          />
          Reactor Power (%):
          <ProgressBar
            value={data.power}
            minValue={0}
            maxValue={100}
            color="yellow"
          />
          Reactor Pressure (kPa):
          <ProgressBar
            value={data.kpa}
            minValue={0}
            maxValue={8200}
            color="white"
          >
            {data.kpa} kPa
          </ProgressBar>
          Coolant temperature (°K):
          <ProgressBar
            value={data.coolantInput}
            minValue={0}
            maxValue={1200}
            color="blue"
          >
            {data.coolantInput} °K
          </ProgressBar>
          Outlet temperature (°K):
          <ProgressBar
            value={data.coolantOutput}
            minValue={0}
            maxValue={1200}
            color="bad"
          >
            {data.coolantOutput} °K
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
