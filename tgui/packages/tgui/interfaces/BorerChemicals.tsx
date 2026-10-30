import { useBackend, useLocalState } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Secretion = {
  name: string;
  path: string;
  cost: number;
  dose_size: number;
};

type HostReagent = {
  name: string;
  path: string;
  volume: number;
};

type BorerChemicalsData = {
  chemicals: number;
  max_chemicals: number;
  host_name: string;
  host_zone: string;
  host_full: boolean;
  dose_amounts: number[];
  secretions: Secretion[];
  can_analyze_host: boolean;
  can_purge: boolean;
  purge_ready: boolean;
  host_reagents?: HostReagent[];
  host_current_volume?: number;
  host_max_volume?: number;
};

export const BorerChemicals = () => {
  const { act, data } = useBackend<BorerChemicalsData>();
  const {
    chemicals,
    max_chemicals,
    host_name,
    host_zone,
    host_full,
    dose_amounts,
    secretions,
    can_analyze_host,
    can_purge,
    purge_ready,
    host_reagents = [],
    host_current_volume = 0,
    host_max_volume = 0,
  } = data;
  const [dose, setDose] = useLocalState('dose', 5);

  return (
    <Window theme="neutral" width={560} height={560}>
      <Window.Content scrollable>
        <Section title="Chemical Reserve">
          <ProgressBar
            value={chemicals}
            minValue={0}
            maxValue={max_chemicals}
            color="green"
          >
            <AnimatedNumber value={chemicals} /> / {max_chemicals} chemicals
          </ProgressBar>
          <Box color="label" mt={1}>
            Host: {host_name} — {host_zone}
          </Box>
        </Section>

        <Section
          title="Secretions"
          buttons={dose_amounts.map((amount) => (
            <Button
              key={amount}
              icon="syringe"
              selected={dose === amount}
              content={`${amount}u`}
              onClick={() => setDose(amount)}
            />
          ))}
        >
          {!secretions.length ? (
            <NoticeBox>
              Your current cyst location cannot produce any secretions.
            </NoticeBox>
          ) : (
            <Box mr={-1}>
              {secretions.map((secretion) => {
                const cost = (secretion.cost * dose) / secretion.dose_size;
                return (
                  <Button
                    key={secretion.path}
                    icon="tint"
                    width="168px"
                    lineHeight="21px"
                    disabled={host_full || chemicals < cost}
                    tooltip={`${dose} units for ${cost} chemicals`}
                    onClick={() =>
                      act('secrete', { path: secretion.path, dose })
                    }
                  >
                    {secretion.name}
                    <Box color="label">{cost} chemicals</Box>
                  </Button>
                );
              })}
            </Box>
          )}
        </Section>

        <Section
          title="Host Bloodstream"
          buttons={
            !!can_purge && (
              <Button
                icon="filter"
                color="bad"
                content="Purge (30 chemicals)"
                disabled={!purge_ready || chemicals < 30}
                tooltip="Removes ALL host reagents, including medicine. Shares the Metabolic Purge action's 60-second cooldown."
                onClick={() => act('purge')}
              />
            )
          }
        >
          {!can_analyze_host ? (
            <NoticeBox info>
              Evolve Taste Blood to identify chemicals in your host.
            </NoticeBox>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Total volume">
                <ProgressBar
                  value={host_current_volume}
                  minValue={0}
                  maxValue={host_max_volume}
                  color="red"
                >
                  <AnimatedNumber value={host_current_volume} /> /{' '}
                  {host_max_volume} units
                </ProgressBar>
              </LabeledList.Item>
              <LabeledList.Item label="Contents">
                {!host_reagents.length ? (
                  <Box color="label">Nothing detected</Box>
                ) : (
                  <Stack vertical>
                    {host_reagents.map((reagent) => (
                      <Stack.Item key={reagent.path}>
                        <AnimatedNumber value={reagent.volume} /> units of{' '}
                        {reagent.name}
                      </Stack.Item>
                    ))}
                  </Stack>
                )}
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
