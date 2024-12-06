import { useBackend } from '../backend';
import { Button, Section, Table, NoticeBox, Dimmer, Box } from '../components';
import { NtosWindow } from '../layouts';

export const NtosPaycheckManager = (props, context) => {
  return (
    <NtosWindow width={400} height={620}>
      <NtosWindow.Content scrollable>
        <NtosPaycheckManagerContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

export const NtosPaycheckManagerContent = (props, context) => {
  const { act, data } = useBackend(context);

  const { authed, cooldown, slots = [], prioritized = [] } = data;

  if (!authed) {
    return <NoticeBox>Current ID does not have access permissions to change job slots.</NoticeBox>;
  }

  return <Section />;
};
