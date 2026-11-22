import {
  Button,
  Dropdown,
  Input,
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
} & NaniteProgram;

export function NaniteProgrammer(props) {
  return (
    <Window width={500} height={550}>
      <Window.Content scrollable>
        <NaniteProgrammerContent />
      </Window.Content>
    </Window>
  );
}

export function NaniteProgrammerContent(props) {
  const { act, data } = useBackend<Data>();
  const {
    has_disk,
    has_program,
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    activated,
    has_extra_settings,
    extra_settings = [],
  } = data;

  return (
    <Section
      title={has_program ? `Program Disk: ${name}` : 'Program Disk'}
      fill
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
        <Stack vertical p={1}>
          <Stack.Item>
            <Stack>
              <Stack.Item>{desc}</Stack.Item>

              <Stack.Divider />

              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item label="Status">
                    <Button
                      icon={activated ? 'power-off' : 'times'}
                      selected={activated}
                      color="bad"
                      bold
                      onClick={() => act('toggle_active')}
                    >
                      {activated ? 'Active' : 'Inactive'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Use Rate">
                    {use_rate}
                  </LabeledList.Item>
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
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <br />

          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <ProgramCodes />
              </Stack.Item>
              <Stack.Item grow>
                <ProgramDelays />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          {!!has_extra_settings && (
            <Stack.Item>
              <Section title="Special">
                <LabeledList>
                  {extra_settings.map((setting) => (
                    <NaniteExtraEntry
                      key={setting.name}
                      extra_setting={setting}
                    />
                  ))}
                </LabeledList>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      )}
    </Section>
  );
}

function ProgramCodes(props) {
  const { act, data } = useBackend<Data>();
  const {
    activation_code,
    deactivation_code,
    kill_code,
    trigger_code,
    can_trigger,
  } = data;

  return (
    <Section title="Codes" fill mr={0.5}>
      <LabeledList>
        <LabeledList.Item label="Activation">
          <NumberInput
            value={activation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'activation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Deactivation">
          <NumberInput
            value={deactivation_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'deactivation',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Kill">
          <NumberInput
            value={kill_code}
            width="47px"
            minValue={0}
            maxValue={9999}
            step={1}
            onChange={(value) =>
              act('set_code', {
                target_code: 'kill',
                code: value,
              })
            }
          />
        </LabeledList.Item>
        {!!can_trigger && (
          <LabeledList.Item label="Trigger">
            <NumberInput
              value={trigger_code}
              width="47px"
              minValue={0}
              maxValue={9999}
              step={1}
              onChange={(value) =>
                act('set_code', {
                  target_code: 'trigger',
                  code: value,
                })
              }
            />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function ProgramDelays(props) {
  const { act, data } = useBackend<Data>();
  const {
    timer_restart,
    timer_shutdown,
    timer_trigger,
    can_trigger,
    timer_trigger_delay,
  } = data;

  return (
    <Section title="Delays" fill ml={0.5}>
      <LabeledList>
        <LabeledList.Item label="Restart Timer">
          <NumberInput
            value={timer_restart}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            step={1}
            onChange={(value) =>
              act('set_restart_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Shutdown Timer">
          <NumberInput
            value={timer_shutdown}
            unit="s"
            width="57px"
            minValue={0}
            maxValue={3600}
            step={1}
            onChange={(value) =>
              act('set_shutdown_timer', {
                delay: value,
              })
            }
          />
        </LabeledList.Item>
        {!!can_trigger && (
          <>
            <LabeledList.Item label="Trigger Repeat Timer">
              <NumberInput
                value={timer_trigger}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                step={1}
                onChange={(value) =>
                  act('set_trigger_timer', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Trigger Delay">
              <NumberInput
                value={timer_trigger_delay}
                unit="s"
                width="57px"
                minValue={0}
                maxValue={3600}
                step={1}
                onChange={(value) =>
                  act('set_timer_trigger_delay', {
                    delay: value,
                  })
                }
              />
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
}

function NaniteExtraEntry(props) {
  const { extra_setting } = props;
  const { name, type } = extra_setting;

  const typeComponentMap = {
    number: <NaniteExtraNumber extra_setting={extra_setting} />,
    text: <NaniteExtraText extra_setting={extra_setting} />,
    type: <NaniteExtraType extra_setting={extra_setting} />,
    boolean: <NaniteExtraBoolean extra_setting={extra_setting} />,
  };
  return (
    <LabeledList.Item label={name}>{typeComponentMap[type]}</LabeledList.Item>
  );
}

function NaniteExtraNumber(props) {
  const { act } = useBackend();

  const { extra_setting } = props;
  const { name, value, min, max, unit } = extra_setting;

  return (
    <NumberInput
      value={value}
      width="64px"
      minValue={min}
      maxValue={max}
      unit={unit}
      step={1}
      onChange={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
}

function NaniteExtraText(props) {
  const { act } = useBackend();

  const { extra_setting } = props;
  const { name, value } = extra_setting;

  return (
    <Input
      value={value}
      width="200px"
      onInput={(e, val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
}

function NaniteExtraType(props) {
  const { act } = useBackend();

  const { extra_setting } = props;
  const { name, value, types } = extra_setting;

  return (
    <Dropdown
      over
      selected={value}
      width="150px"
      options={types}
      onSelected={(val) =>
        act('set_extra_setting', {
          target_setting: name,
          value: val,
        })
      }
    />
  );
}

function NaniteExtraBoolean(props) {
  const { act } = useBackend();

  const { extra_setting } = props;
  const { name, value, true_text, false_text } = extra_setting;

  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('set_extra_setting', {
          target_setting: name,
        })
      }
    >
      {value ? true_text : false_text}
    </Button.Checkbox>
  );
}
