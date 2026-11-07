import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import type { NaniteProgram } from './common/NaniteTypes';

type Data = {
  has_disk: BooleanLike;
  has_program: BooleanLike;
  disk: NaniteProgram;
  current_view: number;
  cloud_backup: BooleanLike;
  cloud_backups: number[];
  cloud_programs: NaniteProgram[];
};

export function NaniteCloudControl(props) {
  return (
    <Window width={450} height={700}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <NaniteDiskBox />
          </Stack.Item>
          <Stack.Item grow>
            <CloudStorage />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}

function NaniteDiskBox(props) {
  const { data, act } = useBackend<Data>();
  const { has_disk, has_program, disk } = data;

  return (
    <Section
      title={has_program ? `Program Disk: ${disk.name}` : 'Program Disk'}
      buttons={
        <Button icon="eject" disabled={!has_disk} onClick={() => act('eject')}>
          Eject
        </Button>
      }
    >
      {!has_disk ? (
        <NoticeBox>No Disk Inserted</NoticeBox>
      ) : !has_program ? (
        <NoticeBox>No Program Installed</NoticeBox>
      ) : (
        <ProgramInfoBox program={disk} />
      )}
    </Section>
  );
}

function CloudStorage(props) {
  const { data, act } = useBackend<Data>();
  const { current_view, has_program } = data;

  const [newBackupId, setNewBackupId] = useState(0);

  return current_view === 0 ? (
    <Section
      title="Cloud Storage"
      fill
      scrollable
      buttons={
        <>
          {'New Backup: '}
          <NumberInput
            value={newBackupId}
            minValue={1}
            maxValue={100}
            step={1}
            stepPixelSize={4}
            width="39px"
            onChange={(value) => setNewBackupId(value)}
          />
          <Button
            icon="plus"
            onClick={() => act('create_backup', { value: newBackupId })}
          />
        </>
      }
    >
      <NaniteCloudBackupList />
    </Section>
  ) : (
    <Section
      title={`Cloud Storage: Backup #${current_view}`}
      fill
      scrollable
      buttons={
        <>
          <Button
            icon="upload"
            color="good"
            disabled={!has_program}
            onClick={() => act('upload_program')}
          >
            Upload From Disk
          </Button>
          <Button
            icon="arrow-left"
            onClick={() =>
              act('set_view', {
                view: 0,
              })
            }
          >
            Return
          </Button>
        </>
      }
    >
      <NaniteCloudBackupDetails />
    </Section>
  );
}

function NaniteCloudBackupList(props) {
  const { act, data } = useBackend<Data>();
  const { cloud_backups = [] } = data;

  return (
    <Stack vertical>
      {cloud_backups.map((backupNumber) => (
        <Stack.Item key={backupNumber}>
          <Button
            fluid
            textAlign="center"
            onClick={() =>
              act('set_view', {
                view: backupNumber,
              })
            }
          >
            {`Backup #${backupNumber}`}
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

function NaniteCloudBackupDetails(props) {
  const { data } = useBackend<Data>();
  const { disk, cloud_backup, cloud_programs = [] } = data;

  if (!cloud_backup) {
    return <NoticeBox> ERROR: Backup not found</NoticeBox>;
  }

  return (
    <Stack vertical>
      {cloud_programs.map((program) => (
        <ProgramEntry key={program.id} program={program} disk={disk} />
      ))}
    </Stack>
  );
}

function ProgramEntry(props) {
  const { program, disk } = props;
  const { act } = useBackend();

  const [combineSelection, setCombineSelection] = useState(false);
  const [toCombine, setToCombine] = useState<number[]>([]);
  const [combineOp, setCombineOp] = useState('AND');

  const can_rule = disk?.can_rule || false;

  const rules = program.rules || [];
  return (
    <Stack.Item key={program.name} grow>
      <Collapsible
        title={program.name}
        buttons={
          <Button
            icon="minus-circle"
            color="bad"
            onClick={() =>
              act('remove_program', {
                program_id: program.id,
              })
            }
          />
        }
      >
        <>
          <ProgramInfoBox program={program} />
          {toCombine.map((id) => (
            <Box key={id}>{id}</Box>
          ))}
          {(can_rule || program.has_rules) && (
            <Section
              p={1}
              title="Rules"
              buttons={
                !!can_rule && (
                  <Stack>
                    <Stack.Item>
                      <Button
                        icon="plus"
                        color="good"
                        onClick={() =>
                          act('add_rule', {
                            program_id: program.id,
                          })
                        }
                      >
                        Add Rule from Disk
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        selected={combineSelection}
                        onClick={() => {
                          if (combineSelection) {
                            setCombineSelection(false);
                            if (toCombine.length <= 0) {
                              return;
                            }
                            act('combine_rules', {
                              program_id: program.id,
                              rule_ids: toCombine,
                              op: combineOp,
                            });
                          } else {
                            setCombineSelection(true);
                          }
                          setToCombine([]);
                        }}
                      >
                        Combine
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Dropdown
                        width="75px"
                        disabled={!combineSelection}
                        selected={combineOp}
                        options={['AND', 'OR', 'NOR', 'NAND']}
                        onSelected={(value) => setCombineOp(value)}
                      />
                    </Stack.Item>
                  </Stack>
                )
              }
            >
              {program.has_rules ? (
                <Stack vertical>
                  {rules.map((rule) => (
                    <Stack.Item key={rule.display}>
                      {combineSelection && (
                        <Button.Checkbox
                          checked={toCombine.includes(rule.id)}
                          onClick={() => {
                            if (toCombine.includes(rule.id)) {
                              toCombine.splice(rule.id);
                            } else {
                              toCombine.push(rule.id);
                            }
                          }}
                        />
                      )}

                      <Button
                        icon="minus-circle"
                        color="bad"
                        onClick={() =>
                          act('remove_rule', {
                            program_id: program.id,
                            rule_id: rule.id,
                          })
                        }
                      >
                        {`${rule.display} ${rule.id} ${toCombine.includes(rule.id) ? 'true' : 'false'}`}
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
              ) : (
                <Box color="bad">No Active Rules</Box>
              )}
            </Section>
          )}
        </>
      </Collapsible>
    </Stack.Item>
  );
}

function ProgramInfoBox(props) {
  const { program } = props;

  const {
    desc,
    activated,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    timer_restart,
    timer_shutdown,
    timer_trigger,
    timer_trigger_delay,
    extra_settings = [],
  } = program;

  return (
    <Stack vertical p={1}>
      <Stack.Item>
        <Stack>
          <Stack.Item>{desc}</Stack.Item>

          <Stack.Divider />

          <Stack.Item>
            <ProgramBasicInfo
              activated={activated}
              use_rate={use_rate}
              trigger_cost={trigger_cost}
              trigger_cooldown={trigger_cooldown}
              can_trigger={can_trigger}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <br />

      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <ProgramCodes
              activation_code={activation_code}
              deactivation_code={deactivation_code}
              kill_code={kill_code}
              trigger_code={trigger_code}
              can_trigger={can_trigger}
            />
          </Stack.Item>

          <Stack.Item grow>
            <ProgramDelays
              timer_restart={timer_restart}
              timer_shutdown={timer_shutdown}
              timer_trigger={timer_trigger}
              timer_trigger_delay={timer_trigger_delay}
              can_trigger={can_trigger}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item>
        <ProgramExtraInfo extra_settings={extra_settings} />
      </Stack.Item>
    </Stack>
  );
}

function ProgramBasicInfo(props) {
  const { activated, use_rate, trigger_cost, trigger_cooldown, can_trigger } =
    props;

  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        <Box bold color={activated ? 'good' : 'bad'}>
          {activated ? 'Activated' : 'Deactivated'}
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Use Rate">{use_rate}</LabeledList.Item>
      {!!can_trigger && (
        <>
          <LabeledList.Item label="Trigger Cost">
            {trigger_cost}
          </LabeledList.Item>
          <LabeledList.Item label="Trigger Cooldown">
            {trigger_cooldown}
          </LabeledList.Item>
        </>
      )}
    </LabeledList>
  );
}

function ProgramCodes(props) {
  const {
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    can_trigger,
  } = props;

  return (
    <Section title="Codes" fill mr={0.5}>
      <LabeledList>
        <LabeledList.Item label="Activation">
          {activation_code}
        </LabeledList.Item>
        <LabeledList.Item label="Deactivation">
          {deactivation_code}
        </LabeledList.Item>
        <LabeledList.Item label="Kill">{kill_code}</LabeledList.Item>
        {!!can_trigger && (
          <LabeledList.Item label="Trigger">{trigger_code}</LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramDelays(props) {
  const {
    timer_restart,
    timer_shutdown,
    timer_trigger,
    timer_trigger_delay,
    can_trigger,
  } = props;

  return (
    <Section title="Delays" fill ml={0.5}>
      <LabeledList>
        <LabeledList.Item label="Restart">{timer_restart} s</LabeledList.Item>
        <LabeledList.Item label="Shutdown">{timer_shutdown} s</LabeledList.Item>
        {!!can_trigger && (
          <>
            <LabeledList.Item label="Trigger">
              {timer_trigger} s
            </LabeledList.Item>
            <LabeledList.Item label="Trigger Delay">
              {timer_trigger_delay} s
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramExtraInfo(props) {
  const { extra_settings } = props;

  return (
    <Section title="Extra Settings">
      <LabeledList>
        {extra_settings.map((setting) => {
          const naniteTypesDisplayMap = {
            number: (
              <>
                {setting.value}
                {setting.unit}
              </>
            ),
            text: setting.value,
            type: setting.value,
            boolean: setting.value ? setting.true_text : setting.false_text,
          };
          return (
            <LabeledList.Item key={setting.name} label={setting.name}>
              {naniteTypesDisplayMap[setting.type]}
            </LabeledList.Item>
          );
        })}
      </LabeledList>
    </Section>
  );
}
