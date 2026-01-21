import { useBackend } from '../backend';
import { Button, Flex, Graph, Knob, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const AtmosMdr = (props) => {
  const { act, data } = useBackend();
  const {
    toroid_spin,
    parabolic_setting,
    parabolic_upper_limit,
    parabolic_ratio,
    input_volume,
    toroid_flux_mult,
    core_temperature,
    core_composition,
    can_activate,
    activated,
    metallization_ratio,
    core_stability,
    core_instability,
  } = data;
  return (
    <Window theme="ntos" width={480} height={500}>
      <Window.Content>
        <Section>
          <Button
            icon={'power-off'}
            content={'Activate'}
            selected={activated}
            disabled={!can_activate}
            onClick={() => act('activate')}
          />
          <br />
          <Knob
            size={1.25}
            color={'yellow'}
            value={metallization_ratio}
            unit=""
            minValue={0.1}
            maxValue={1}
            step={0.1}
            stepPixelSize={1}
            onDrag={(e, value) =>
              act('change_metal_ratio', {
                change_metal_ratio: value,
              })
            }
          />
          <br />
          Core Stability:
          {core_stability}
          <br />
          Core Instability:
          {core_instability}
          <br />
          Delta Stability:
          {core_stability - core_instability}
          <br />
          Toroid Spin:
          {toroid_spin}
          <br />
          Parabolic Setting:
          {parabolic_setting}
          <br />
          Toroid Flux Mult:
          {toroid_flux_mult}
          <br />
          Core Temperature:
          {core_temperature}
          <br />
          Core Comp:
          {Object.keys(core_composition).map((key) => (
            <div key={key}>
              {key}: {core_composition[key]}
            </div>
          ))}
          <br />
          <NumberInput
            animated
            value={parseFloat(input_volume)}
            width="75px"
            unit="L/s"
            minValue={0}
            maxValue={200}
            step={10}
            onChange={(value) =>
              act('change_input', {
                change_input: value,
              })
            }
          />
          <Flex direction="column">
            <Flex.Item position="absolute">
                <svg>
            <rect
            x={1}
            width="100"
            height="100"
            y={1}
            fill="grey"
            />
                </svg>
            </Flex.Item>
            <Flex.Item grow={1}>
          <Graph
            funct={(i) => { return -((i - Math.sqrt(parabolic_setting * parabolic_upper_limit))**2) + parabolic_setting * parabolic_upper_limit; }}
            upperLimit={parabolic_upper_limit}
            lowerLimit={0}
            leftLimit={0}
            rightLimit={(2 * Math.sqrt(parabolic_upper_limit * parabolic_setting)) + (2 * Math.sqrt(parabolic_upper_limit * parabolic_setting) * 0.1)}
            steps={25}
          />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
