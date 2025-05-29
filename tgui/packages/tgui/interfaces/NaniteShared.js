import { useBackend } from '../backend';
import { Box, Button, Dropdown, Grid, Icon, Input, LabeledList, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';

const NaniteCodes = (props) => {
  const { act } = useBackend();

  const { program, read_only } = props;

  const {
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    maximum_duration,
    activated,
    has_extra_settings,
    extra_settings = {},
    activation_code,
    deactivation_code,
    trigger_code,
    kill_code,
  } = program;

  return (
    <Section title="Codes" level={3} mr={1}>
      <LabeledList>
        {!can_trigger && (
          <>
            <LabeledList.Item label="Activation" tooltip="When the program receives this code, the effects will be activated.">
              {read_only ? (
                activation_code
              ) : (
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
              )}
            </LabeledList.Item>
            <LabeledList.Item
              label="Deactivation"
              tooltip="When the program receives this code, the effects will be deactivated.">
              {read_only ? (
                deactivation_code
              ) : (
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
              )}
            </LabeledList.Item>
          </>
        )}
        {!!can_trigger && (
          <LabeledList.Item label="Trigger" tooltip="When the program receives this code, the effect will be activated.">
            {read_only ? (
              trigger_code
            ) : (
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
            )}
          </LabeledList.Item>
        )}
        <LabeledList.Item
          label="Kill"
          tooltip="If set to a non-zero value, when the code is received the program will be removed from the user.">
          {read_only ? (
            kill_code
          ) : (
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
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const NaniteDelays = (props) => {
  const { act } = useBackend();

  const { program, read_only } = props;

  const {
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    maximum_duration,
    activated,
    has_extra_settings,
    extra_settings = {},
    timer_restart,
    timer_shutdown,
    timer_trigger_delay,
  } = program;

  return (
    <Section title="Delays" level={3} ml={1}>
      <LabeledList>
        <LabeledList.Item
          label={can_trigger ? 'Re-trigger Timer' : 'Re-activate Timer'}
          tooltip={
            can_trigger
              ? 'When the effects of this program finish or when a trigger fails, the trigger will be re-attempted after this amount of time forming a loop.'
              : 'When the program deactivates, it will attempt to reactivate after this amount of time.'
          }>
          {read_only ? (
            timer_restart
          ) : (
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
          )}
        </LabeledList.Item>
        {!read_only && !!timer_restart && timer_restart < trigger_cooldown && (
          <LabeledList.Item>
            <NoticeBox color="red">
              <Icon name="warning" color="yellow" mr={1} />
              Duration shorter than cooldown
            </NoticeBox>
          </LabeledList.Item>
        )}
        {!can_trigger && (
          <LabeledList.Item
            label="Shutdown Timer"
            tooltip="After a set amount of seconds, the program will automatically deactivate if this is set.">
            {read_only ? (
              timer_shutdown
            ) : (
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
            )}
          </LabeledList.Item>
        )}
        {!!can_trigger && (
          <LabeledList.Item
            label="Trigger Delay"
            tooltip="The delay between the trigger signal being received and the effects being activated.">
            {read_only ? (
              timer_trigger_delay
            ) : (
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
            )}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const NaniteExtraEntry = (props) => {
  const { extra_setting, read_only } = props;
  const { name, type, value } = extra_setting;
  if (read_only) {
    return <LabeledList.Item label={name}>{value}</LabeledList.Item>;
  }
  const typeComponentMap = {
    number: <NaniteExtraNumber extra_setting={extra_setting} />,
    text: <NaniteExtraText extra_setting={extra_setting} />,
    type: <NaniteExtraType extra_setting={extra_setting} />,
    boolean: <NaniteExtraBoolean extra_setting={extra_setting} />,
  };
  return <LabeledList.Item label={name}>{typeComponentMap[type]}</LabeledList.Item>;
};

const NaniteExtraNumber = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
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
};

const NaniteExtraText = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
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
};

const NaniteExtraType = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
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
};

const NaniteExtraBoolean = (props) => {
  const { extra_setting } = props;
  const { act } = useBackend();
  const { name, value, true_text, false_text } = extra_setting;
  return (
    <Button.Checkbox
      content={value ? true_text : false_text}
      checked={value}
      onClick={() =>
        act('set_extra_setting', {
          target_setting: name,
        })
      }
    />
  );
};

export const NaniteInfoGrid = (props) => {
  const { act } = useBackend();
  const { program, read_only } = props;
  const {
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    maximum_duration,
    activated,
    has_extra_settings,
    extra_settings = {},
  } = program;

  return (
    <Section
      title={name}
      buttons={
        read_only ? (
          can_trigger ? (
            <Box bold color="orange">
              Triggered
            </Box>
          ) : activated ? (
            <Box bold color="green">
              Activated
            </Box>
          ) : (
            <Box bold color="red">
              Deactivated
            </Box>
          )
        ) : can_trigger ? (
          <Box bold color="orange">
            Triggered
          </Box>
        ) : (
          <Button
            icon={activated ? 'power-off' : 'times'}
            content={activated ? 'Active' : 'Inactive'}
            selected={activated}
            color={'bad'}
            bold
            onClick={() => act('toggle_active')}
          />
        )
      }>
      <Grid>
        <Grid.Column>{desc}</Grid.Column>
        <Grid.Column size={0.7}>
          <LabeledList>
            {!can_trigger || !maximum_duration ? (
              <LabeledList.Item label="Use Rate">{use_rate}</LabeledList.Item>
            ) : (
              <LabeledList.Item label="Activation Cost">{use_rate * maximum_duration}</LabeledList.Item>
            )}
            {!!can_trigger && (
              <>
                {(!!trigger_cost || !maximum_duration) && (
                  <LabeledList.Item label="Trigger Cost">{trigger_cost}</LabeledList.Item>
                )}
                <LabeledList.Item label="Trigger Cooldown">{trigger_cooldown}s</LabeledList.Item>
                {!!maximum_duration && <LabeledList.Item label="Effect Duration">{maximum_duration}s</LabeledList.Item>}
              </>
            )}
          </LabeledList>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

export const NaniteSettings = (props) => {
  const { program, read_only } = props;

  const {
    name,
    desc,
    use_rate,
    can_trigger,
    trigger_cost,
    trigger_cooldown,
    maximum_duration,
    activated,
    has_extra_settings,
    extra_settings = {},
  } = program;

  return (
    <Section title="Settings" level={2}>
      <Grid>
        <Grid.Column>
          <NaniteCodes program={program} read_only={read_only} />
        </Grid.Column>
        <Grid.Column>
          <NaniteDelays program={program} read_only={read_only} />
        </Grid.Column>
      </Grid>
      {!!has_extra_settings && (
        <Section title="Special" level={3}>
          <LabeledList>
            {extra_settings.map((setting) => (
              <NaniteExtraEntry key={setting.name} extra_setting={setting} read_only={read_only} />
            ))}
          </LabeledList>
        </Section>
      )}
    </Section>
  );
};
