import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { NaniteProgram } from './common/NaniteTypes';

type Data = {
  status_msg: number;
  locked: BooleanLike;
  occupant_name: string;
  has_nanites: BooleanLike[];
  nanite_volume: number;
  regen_rate: number;
  safety_threshold: number;
  cloud_id: number;
  scan_level: number;
  mob_programs: NaniteProgram[];
};

enum ScanLevel {
  Baseline = 2,
  Greater = 3,
  Advanced = 4,
}

export function NaniteChamberControl(props) {
  return (
    <Window width={460} height={570}>
      <Window.Content>
        <NaniteChamberControlContent />
      </Window.Content>
    </Window>
  );
}

function NaniteChamberControlContent(props) {
  const { act, data } = useBackend<Data>();

  const {
    status_msg,
    locked,
    occupant_name,
    has_nanites,
    nanite_volume,
    regen_rate,
    safety_threshold,
    cloud_id,
    mob_programs = [],
  } = data;

  if (status_msg) {
    return <NoticeBox textAlign="center">{status_msg}</NoticeBox>;
  }

  return (
    <Section
      title={`Chamber: ${occupant_name}`}
      fill
      buttons={
        <>
          <Button
            icon={locked ? 'lock' : 'lock-open'}
            color={locked ? 'bad' : 'default'}
            onClick={() => act('toggle_lock')}
          >
            {locked ? 'Locked' : 'Unlocked'}
          </Button>
          {has_nanites && (
            <Button
              icon="exclamation-triangle"
              color="bad"
              onClick={() => act('remove_nanites')}
            >
              Destroy Nanites
            </Button>
          )}
        </>
      }
    >
      {!has_nanites ? (
        <>
          <Box bold color="bad" textAlign="center" fontSize="30px" mb={1}>
            No Nanites Detected
          </Box>

          <Button
            fluid
            bold
            icon="syringe"
            color="green"
            textAlign="center"
            fontSize="30px"
            lineHeight="50px"
            onClick={() => act('nanite_injection')}
          >
            Implant Nanites
          </Button>
        </>
      ) : (
        <Stack fill vertical p={1}>
          <Stack.Item>
            <Stack>
              <Stack.Item grow align="center">
                <Stack vertical>
                  <LabeledList>
                    <LabeledList.Item label="Nanite Volume">
                      {nanite_volume}
                    </LabeledList.Item>
                    <LabeledList.Item label="Growth Rate">
                      {regen_rate}/s
                    </LabeledList.Item>
                  </LabeledList>
                </Stack>
              </Stack.Item>

              <Stack.Divider />

              <Stack.Item grow align="center">
                <Stack vertical>
                  <LabeledList>
                    <LabeledList.Item label="Safety Threshold">
                      <NumberInput
                        value={safety_threshold}
                        minValue={0}
                        maxValue={500}
                        width="39px"
                        step={1}
                        onChange={(value) => act('set_safety', { value })}
                      />
                    </LabeledList.Item>

                    <LabeledList.Item label="Cloud ID">
                      <NumberInput
                        value={cloud_id}
                        minValue={0}
                        maxValue={100}
                        step={1}
                        stepPixelSize={3}
                        width="39px"
                        onChange={(value) => act('set_cloud', { value })}
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Divider />

          {mob_programs.length > 0 && (
            <Stack.Item grow>
              <Section title="Programs" fill scrollable>
                {mob_programs.map((program) => (
                  <Collapsible key={program.name} title={program.name}>
                    <ProgramContent program={program} />
                  </Collapsible>
                ))}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      )}
    </Section>
  );
}

function ProgramContent(props) {
  const { data } = useBackend<Data>();
  const { scan_level } = data;

  const { program } = props;

  return (
    <Stack vertical pt={1} pb={1} pl={2} pr={2}>
      <Stack.Item grow>{program.desc}</Stack.Item>

      {scan_level >= ScanLevel.Baseline && (
        <>
          <Stack.Divider />
          <Stack.Item>
            <ProgramStatus program={program} />
          </Stack.Item>
          {!!program.can_trigger && (
            <>
              <Stack.Divider />
              <Stack.Item>
                <ProgramTriggers program={program} />
              </Stack.Item>
            </>
          )}
          {(!!program.timer_restart || !!program.timer_shutdown) && (
            <>
              <Stack.Divider />
              <Stack.Item>
                <ProgramTimers program={program} />
              </Stack.Item>
            </>
          )}
        </>
      )}

      {scan_level >= ScanLevel.Greater && !!program.has_extra_settings && (
        <>
          <Stack.Divider />
          <Stack.Item>
            <ProgramExtraSettings program={program} />
          </Stack.Item>
        </>
      )}

      {scan_level >= ScanLevel.Advanced && (
        <>
          {(!!program.activation_code ||
            !!program.deactivation_code ||
            !!program.kill_code ||
            (!!program.can_trigger && !!program.trigger_code)) && (
            <>
              <Stack.Divider />
              <Stack.Item>
                <ProgramCodes program={program} />
              </Stack.Item>
            </>
          )}
          {!!program.has_rules && (
            <>
              <Stack.Divider />
              <Stack.Item>
                <ProgramRules program={program} />
              </Stack.Item>
            </>
          )}
        </>
      )}
    </Stack>
  );
}

function ProgramStatus(props) {
  const { program } = props;

  return (
    <Section title="Program Status">
      <LabeledList>
        <LabeledList.Item label="Activation Status">
          <Box color={program.activated ? 'good' : 'bad'}>
            {program.activated ? 'Active' : 'Inactive'}
          </Box>
        </LabeledList.Item>

        <LabeledList.Item label="Nanite Use">
          {program.use_rate}/s
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function ProgramTriggers(props) {
  const { program } = props;

  return (
    <Section title="Triggers">
      <LabeledList>
        <LabeledList.Item label="Trigger Cost">
          {program.trigger_cost}
        </LabeledList.Item>

        <LabeledList.Item label="Trigger Cooldown">
          {program.trigger_cooldown}
        </LabeledList.Item>

        {!!program.timer_trigger_delay && (
          <LabeledList.Item label="Trigger Delay">
            {program.timer_trigger_delay}s
          </LabeledList.Item>
        )}

        {!!program.timer_trigger && (
          <LabeledList.Item label="Trigger Repeat Timer">
            {program.timer_trigger}s
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramTimers(props) {
  const { program } = props;

  return (
    <Section title="Timers">
      <LabeledList>
        {!!program.timer_restart && (
          <LabeledList.Item label="Restart Timer">
            {program.timer_restart} s
          </LabeledList.Item>
        )}

        {!!program.timer_shutdown && (
          <LabeledList.Item label="Shutdown Timer">
            {program.timer_shutdown} s
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramCodes(props) {
  const { program } = props;

  return (
    <Section title="Codes">
      <LabeledList>
        {!!program.activation_code && (
          <LabeledList.Item label="Activation">
            {program.activation_code}
          </LabeledList.Item>
        )}

        {!!program.deactivation_code && (
          <LabeledList.Item label="Deactivation">
            {program.deactivation_code}
          </LabeledList.Item>
        )}

        {!!program.kill_code && (
          <LabeledList.Item label="Kill">{program.kill_code}</LabeledList.Item>
        )}

        {!!program.can_trigger && !!program.trigger_code && (
          <LabeledList.Item label="Trigger">
            {program.trigger_code}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramRules(props) {
  const { program } = props;

  return (
    <Section title="Rules">
      {program.rules.map((rule) => (
        <Box key={rule.display}>{rule.display}</Box>
      ))}
    </Section>
  );
}

function ProgramExtraSettings(props) {
  const { program } = props;

  return (
    <Section title="Extra Settings">
      <LabeledList>
        {program.extra_settings.map((extra_setting) => (
          <LabeledList.Item key={extra_setting.name} label={extra_setting.name}>
            {extra_setting.value}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
}
