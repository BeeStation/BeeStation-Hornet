import { toFixed } from 'common/math';
import { ReactNode } from 'react';

import { useBackend } from '../backend';
import { Chart, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

type RbmkProps = {
  sectionButton?: ReactNode;
  uid: number;
  area_name: string;
  integrity: number;
  coolant_input_temp: number;
  coolant_output_temp: number;
  power: number;
  pressure: number;
  logged_pressure: number[][];
  logged_power: number[][];
  logged_coolant_input_temp: number[][];
  logged_coolant_output_temp: number[][];
};

type RbmkEntryProps = {
  title: string;
  content: ReactNode;
};
const RbmkEntry = (props: RbmkEntryProps) => {
  const { title, content } = props;

  return (
    <Stack.Item>
      <Stack align="center">
        <Stack.Item color="grey" width="125px">
          {title + ':'}
        </Stack.Item>
        <Stack.Item grow>{content}</Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const RbmkContent = (props: RbmkProps) => {
  const {
    sectionButton,
    uid,
    area_name,
    integrity,
    coolant_input_temp,
    coolant_output_temp,
    power,
    pressure,
    logged_pressure,
    logged_power,
    logged_coolant_input_temp,
    logged_coolant_output_temp,
  } = props;

  const pressure_data = logged_pressure.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const power_data = logged_power.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const coolant_input_data = logged_coolant_input_temp.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);
  const coolant_output_data = logged_coolant_output_temp.map((value, i) => [
    i,
    Array.isArray(value) ? value[0] : value,
  ]);

  return (
    <Stack height="100%">
      <Stack.Item grow>
        <Section fill title={uid + '. ' + area_name} buttons={sectionButton}>
          <Stack vertical>
            <RbmkEntry
              title="Integrity"
              content={
                <ProgressBar
                  value={integrity / 100}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.5, 0.9],
                    bad: [-Infinity, 0.5],
                  }}
                >
                  {toFixed(integrity, 2) + ' %'}
                </ProgressBar>
              }
            />
            <RbmkEntry
              title="Reactor Power"
              content={
                <ProgressBar
                  value={power}
                  minValue={0}
                  maxValue={100}
                  ranges={{
                    teal: [-Infinity, 20],
                    good: [20, 75],
                    average: [75, 100],
                    bad: [100, Infinity],
                  }}
                >
                  {toFixed(power, 2) + ' %'}
                </ProgressBar>
              }
            />
            <RbmkEntry
              title="Reactor Pressure"
              content={
                <ProgressBar
                  value={pressure}
                  minValue={0}
                  maxValue={10100}
                  ranges={{
                    teal: [-Infinity, 50],
                    good: [50, 6500],
                    average: [6500, 10100],
                    bad: [10100, Infinity],
                  }}
                >
                  {toFixed(pressure, 2) + ' kPa'}
                </ProgressBar>
              }
            />
            <RbmkEntry
              title="Coolant Inlet Temperature"
              content={
                <ProgressBar
                  value={coolant_input_temp}
                  minValue={0}
                  maxValue={1000}
                  ranges={{
                    teal: [-Infinity, 273],
                    good: [273, 600],
                    average: [600, 1200],
                    bad: [1200, Infinity],
                  }}
                >
                  {toFixed(coolant_input_temp, 2) + ' °K'}
                </ProgressBar>
              }
            />
            <RbmkEntry
              title="Coolant Outlet Temperature"
              content={
                <ProgressBar
                  value={coolant_output_temp}
                  minValue={0}
                  maxValue={1000}
                  ranges={{
                    teal: [-Infinity, 273],
                    good: [273, 600],
                    average: [600, 1200],
                    bad: [1200, Infinity],
                  }}
                >
                  {toFixed(coolant_output_temp, 2) + ' °K'}
                </ProgressBar>
              }
            />
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill title="Reactor Statistics:" scrollable>
          <Stack.Item>
            <Section fill title="Reactor Power:" height="150px">
              <Chart.Line
                fillPositionedParent
                data={power_data}
                rangeX={[0, power_data.length - 1]}
                rangeY={[0, 1500]}
                strokeColor="rgba(255, 215,0, 1)"
                fillColor="rgba(255, 215, 0, 0.1)"
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill title="Reactor Pressure:" height="150px">
              <Chart.Line
                fillPositionedParent
                data={pressure_data}
                rangeX={[0, pressure_data.length - 1]}
                rangeY={[0, 10100]}
                strokeColor="rgba(255,250,250, 1)"
                fillColor="rgba(255,250,250, 0.1)"
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section fill title="Coolant Inlet Temperature:" height="150px">
              <Chart.Line
                fillPositionedParent
                data={coolant_input_data}
                rangeX={[0, coolant_input_data.length - 1]}
                rangeY={[-273.15, 1227]}
                strokeColor="rgba(127, 179, 255 , 1)"
                fillColor="rgba(127, 179, 255 , 0.1)"
              />
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title="Coolant Outlet Temperature:" height="150px">
              <Chart.Line
                fillPositionedParent
                data={coolant_output_data}
                rangeX={[0, coolant_output_data.length - 1]}
                rangeY={[-273.15, 1227]}
                strokeColor="rgba(255, 0, 0 , 1)"
                fillColor="rgba(255, 0, 0 , 0.1)"
              />
            </Section>
          </Stack.Item>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export type RbmkData = {
  rbmk_data: Omit<RbmkProps, 'sectionButton'>[];
};

export const Rbmk = (props) => {
  const { data } = useBackend<RbmkData>();
  const { rbmk_data } = data;
  return (
    <Window width={700} height={400} theme="ntos">
      <Window.Content>
        <RbmkContent {...rbmk_data[0]} />
      </Window.Content>
    </Window>
  );
};
