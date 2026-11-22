import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  is_ready: BooleanLike;
  has_beaker: BooleanLike;
  beaker_empty: BooleanLike;
  has_blood: BooleanLike;
  blood: Blood;
  viruses: Virus[];
  resistances: Resistance[];
};

type Blood = {
  dna: string;
  type: string;
};

type Virus = {
  name: string;
  description: string;
  index: number;
  agent: string;
  spread: string;
  cure: string;
  danger: string;
  can_rename: BooleanLike;
  is_adv: BooleanLike;
  symptoms: Symptom[];
  resistance: number;
  stealth: number;
  stage_speed: number;
  transmission: number;
  symptom_severity: number;
};

type Symptom = {
  name: string;
  desc: string;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  level: number;
  neutered: BooleanLike;
  threshold_desc: string;
  severity: number;
};

type Resistance = {
  id: number;
  name: string;
};

export function Pandemic(props) {
  const { data } = useBackend<Data>();

  return (
    <Window width={520} height={680}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <PandemicBeakerDisplay />
          </Stack.Item>
          {!!data.has_blood && (
            <>
              <Stack.Item>
                <PandemicDiseaseDisplay />
              </Stack.Item>
              <Stack.Item>
                <PandemicAntibodyDisplay />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

function PandemicBeakerDisplay(props) {
  const { act, data } = useBackend<Data>();

  const { has_beaker, beaker_empty, has_blood, blood } = data;

  const cant_empty = !has_beaker || beaker_empty;

  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            icon="times"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          >
            Empty and Eject
          </Button>
          <Button
            icon="trash"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          >
            Empty
          </Button>
          <Button
            icon="eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          >
            Eject
          </Button>
        </>
      }
    >
      {has_beaker ? (
        !beaker_empty ? (
          has_blood ? (
            <LabeledList>
              <LabeledList.Item label="Blood DNA">
                {(blood && blood.dna) || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Blood Type">
                {(blood && blood.type) || 'Unknown'}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="bad">No blood detected</Box>
          )
        ) : (
          <Box color="bad">Beaker is empty</Box>
        )
      ) : (
        <NoticeBox>No beaker loaded</NoticeBox>
      )}
    </Section>
  );
}

function PandemicDiseaseDisplay(props) {
  const { act, data } = useBackend<Data>();
  const { is_ready, viruses = [] } = data;

  return (
    <Stack vertical>
      {viruses.map((virus) => {
        const symptoms = virus.symptoms || [];

        return (
          <Stack.Item key={virus.name}>
            <Section
              title={
                virus.can_rename ? (
                  <Input
                    value={virus.name}
                    onChange={(e, value) =>
                      act('rename_disease', {
                        index: virus.index,
                        name: value,
                      })
                    }
                  />
                ) : (
                  virus.name
                )
              }
              buttons={
                <Button
                  icon="flask"
                  disabled={!is_ready}
                  onClick={() =>
                    act('create_culture_bottle', {
                      index: virus.index,
                    })
                  }
                >
                  Create culture bottle
                </Button>
              }
            >
              <Stack vertical p={1}>
                <Stack.Item>
                  <Stack>
                    <Stack.Item width="50%">{virus.description}</Stack.Item>

                    <Stack.Divider />

                    <Stack.Item width="50%">
                      <LabeledList>
                        <LabeledList.Item label="Agent">
                          {virus.agent}
                        </LabeledList.Item>
                        <LabeledList.Item label="Spread">
                          {virus.spread}
                        </LabeledList.Item>
                        <LabeledList.Item label="Danger">
                          {virus.danger}
                        </LabeledList.Item>
                        <LabeledList.Item label="Possible Cure">
                          {virus.cure}
                        </LabeledList.Item>
                      </LabeledList>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>

                <Stack.Divider />

                {!!virus.is_adv && (
                  <>
                    <Stack.Item>
                      <Section title="Statistics">
                        <Stack>
                          <Stack.Item grow>
                            <LabeledList>
                              <LabeledList.Item label="Resistance">
                                {virus.resistance}
                              </LabeledList.Item>
                              <LabeledList.Item label="Stealth">
                                {virus.stealth}
                              </LabeledList.Item>
                            </LabeledList>
                          </Stack.Item>

                          <Stack.Divider />

                          <Stack.Item grow>
                            <LabeledList>
                              <LabeledList.Item label="Stage speed">
                                {virus.stage_speed}
                              </LabeledList.Item>
                              <LabeledList.Item label="Transmissibility">
                                {virus.transmission}
                              </LabeledList.Item>
                              <LabeledList.Item label="Severity">
                                {virus.symptom_severity}
                              </LabeledList.Item>
                            </LabeledList>
                          </Stack.Item>
                        </Stack>
                      </Section>
                    </Stack.Item>

                    <Stack.Divider />

                    <Stack.Item>
                      <Section title="Symptoms">
                        <Stack vertical p={1}>
                          {symptoms.map((symptom) => (
                            <Stack.Item key={symptom.name}>
                              <Collapsible title={symptom.name}>
                                <PandemicSymptomDisplay symptom={symptom} />
                              </Collapsible>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Section>
                    </Stack.Item>
                  </>
                )}
              </Stack>
            </Section>
          </Stack.Item>
        );
      })}
    </Stack>
  );
}

function PandemicSymptomDisplay(props) {
  const { symptom } = props;
  const {
    name,
    desc,
    stealth,
    resistance,
    stage_speed,
    transmission,
    severity,
    level,
    neutered,
  } = symptom;

  // TODO: Needs proper porting of DM code from tg upstream.
  const thresholds_unsafe = symptom.threshold_desc;

  return (
    <Section
      p={1}
      buttons={
        !!neutered && (
          <Box bold color="bad">
            Neutered
          </Box>
        )
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item width="60%">{desc}</Stack.Item>

            <Stack.Divider />

            <Stack.Item width="40%">
              <LabeledList>
                <LabeledList.Item label="Level">{level}</LabeledList.Item>
                <LabeledList.Item label="Resistance">
                  {resistance}
                </LabeledList.Item>
                <LabeledList.Item label="Stealth">{stealth}</LabeledList.Item>
                <LabeledList.Item label="Stage Speed">
                  {stage_speed}
                </LabeledList.Item>
                <LabeledList.Item label="Transmission">
                  {transmission}
                </LabeledList.Item>
                <LabeledList.Item label="Severity">{severity}</LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Divider />

        <Stack.Item>
          {thresholds_unsafe && (
            <Section title="Thresholds">
              <div
                // eslint-disable-next-line react/no-danger
                dangerouslySetInnerHTML={{
                  __html: thresholds_unsafe,
                }}
              />
            </Section>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function PandemicAntibodyDisplay(props) {
  const { act, data } = useBackend<Data>();
  const { resistances = [] } = data;

  return (
    <Section title="Antibodies">
      {resistances.length > 0 ? (
        <LabeledList>
          {resistances.map((resistance) => (
            <LabeledList.Item key={resistance.name} label={resistance.name}>
              <Button
                icon="eye-dropper"
                disabled={!data.is_ready}
                onClick={() =>
                  act('create_vaccine_bottle', {
                    index: resistance.id,
                  })
                }
              >
                Create vaccine bottle
              </Button>
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Box bold color="bad" mt={1}>
          No antibodies detected.
        </Box>
      )}
    </Section>
  );
}
