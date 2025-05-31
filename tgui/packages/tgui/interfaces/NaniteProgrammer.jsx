import { useBackend } from '../backend';
import { Box, Button, Dropdown, Grid, Icon, Input, LabeledList, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { NaniteInfoGrid, NaniteSettings } from './NaniteShared';

export const NaniteProgrammer = (props) => {
  return (
    <Window width={420} height={550}>
      <Window.Content scrollable>
        <NaniteProgrammerContent />
      </Window.Content>
    </Window>
  );
};

export const NaniteProgrammerContent = (props) => {
  const { act, data } = useBackend();
  const {
    has_disk,
    has_program,
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
  } = data;

  if (!has_disk) {
    return <NoticeBox textAlign="center">Insert a nanite program disk</NoticeBox>;
  }

  if (!has_program) {
    return <Section title="Blank Disk" buttons={<Button icon="eject" content="Eject" onClick={() => act('eject')} />} />;
  }

  return (
    <Section title={name} buttons={<Button icon="eject" content="Eject" onClick={() => act('eject')} />}>
      <NaniteInfoGrid program={data} />
      <NaniteSettings program={data} />
    </Section>
  );
};
