import { NtosWindow } from '../layouts';
import { useBackend } from '../backend';
import { Section, BufferedTextArea, Button } from '../components';

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
          <BufferedTextArea
            fluid
            style={{ height: '100%' }}
            backgroundColor="black"
            textColor="white"
            value={note}
            updateValue={(value) => act('UpdateNote', { newnote: value })}
          />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
