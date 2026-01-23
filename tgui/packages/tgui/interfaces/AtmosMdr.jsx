

import { useBackend } from '../backend';
import { Box, Button, Graph, Knob, NumberInput, Section } from '../components';
import { Window } from '../layouts';
export const AtmosMdr = (props) => {
  const { data } = useBackend();
  return (
  <Window width={480} height={500}>
    <Window.Content>
      <MdrContent {...data} />
    </Window.Content>
  </Window>
  );
};

export const MdrContent = (props) => {
  const { act } = useBackend();
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
  } = props;
  return (
        <Section>
          <Button
            icon={'power-off'}
            content={'Activate'}
            selected={activated}
            disabled={!can_activate}
            onClick={() => act('activate')}
          />
          <Button
            icon={''}
            content={'Activate'}
            onClick={() => act('reconnect')}
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
          {core_composition ? Object.keys(core_composition).map((key) => (
            <div key={key}>
              {key}: {core_composition[key]}
            </div>
          )) : null}
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
          {/* This react code is a tangled, hard-coded mess. If someone wants to try and fix it, be my guest */}
          <Box height={10} width={30} m={1} backgroundColor="grey">
            <Box position="absolute" width={30}>
                <svg width="100%" viewBox={`0 0 ${2 * Math.sqrt(parabolic_upper_limit * parabolic_setting)} ${2 * Math.sqrt(parabolic_upper_limit * parabolic_setting) / 3}`}>
            <rect
            x={Math.min(parabolic_ratio, 2 * Math.sqrt(parabolic_upper_limit * parabolic_setting))}
            width={2 * Math.sqrt(parabolic_upper_limit * parabolic_setting) / 100}
            height="100%"
            y={0}
            fill="red"
            />
                </svg>
            </Box>
            <Box width={30} height="100%">
          <Graph
            funct={(i) => { return -((i - Math.sqrt(parabolic_setting * parabolic_upper_limit))**2) + parabolic_setting * parabolic_upper_limit; }}
            upperLimit={parabolic_upper_limit + (parabolic_upper_limit * 0.01)}
            lowerLimit={0}
            leftLimit={0}
            rightLimit={(2 * Math.sqrt(parabolic_upper_limit * parabolic_setting))}
            steps={25}
          />
            </Box>
          </Box>
        </Section>
  );
};
