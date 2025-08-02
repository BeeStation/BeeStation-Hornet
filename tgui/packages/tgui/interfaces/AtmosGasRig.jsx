import { useBackend } from '../backend';
import { Section, ProgressBar, NumberInput } from '../components';
import { Window } from '../layouts';

export const AtmosGasRig = (props) => {
  const { act, data } = useBackend();
  const depth = data.depth;
  return (
    <Window resizable theme="ntos" width={300} height={300}>
      <Window.Content>
        <Section title="Advanced Gas Rig:">
          Depth:
          <ProgressBar
            minValue={0}
            maxValue={data.max_depth}
            value={depth}
            ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }}
          />
          Shield:
          <ProgressBar
            minValue={0}
            maxValue={data.max_shield}
            value={data.shield_strength}
            ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }}
          />
          <br />
          Set Depth: (K):
          <br />
          <NumberInput
            animated
            value={parseFloat(data.set_depth)}
            width="95px"
            unit="Meters"
            minValue={0}
            maxValue={data.max_depth}
            step={10}
            onChange={(value) =>
              act('set_depth', {
                set_depth: value,
              })
            }
          />
          <br />
          Shielding Strength:
          <br />
          {data.shield_eff}
          <br />
          Gas Power: {data.gas_power}
          <br />
          Specific Heat: {data.specific_heat}
          <br />
          Fracking Efficiency:
          <br />
          {data.fracking_eff}
        </Section>
      </Window.Content>
    </Window>
  );
};
