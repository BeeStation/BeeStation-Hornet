import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Section, TextArea, Button } from '../components';

export const NtosNotepad = (props, context) => {
  const { act, data } = useBackend(context);
  const { note, has_paper } = data;
  return (
    <NtosWindow width={400} height={600}>
      <NtosWindow.Content>
        <Section
          title={'Notes'}
          buttons={!!has_paper && <Button icon="file-alt" content="Show Scanned Paper" onClick={() => act('ShowPaper')} />}
          fill
          fitted>
          <TextArea
            fluid
            style={{ height: '100%' }}
            backgroundColor="black"
            textColor="white"
            onInput={(_, value) => {
              act('UpdateNote', { newnote: value });
            }}
            value={note}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
