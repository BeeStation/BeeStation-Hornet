import { useBackend, useLocalState } from '../backend';
import {
  BufferedTextArea,
  Button,
  Popper,
  Section,
  Stack,
} from '../components';
import { NtosWindow } from '../layouts';

export const NtosNotepad = (props) => {
  const { act, data } = useBackend();
  const { note, has_paper, has_printer } = data;
  const [showOptions, setShowOptions] = useLocalState('show_options', false);

  return (
    <NtosWindow width={400} height={600}>
      <NtosWindow.Content>
        <Section
          title={'Notes'}
          buttons={
            <Popper
              options={{
                placement: 'bottom-start',
              }}
              popperContent={
                (showOptions && (
                  <div className="options_modal">
                    <Stack vertical>
                      <Button.Input
                        fluid
                        content="Save as Log"
                        defaultValue="new_log"
                        onCommit={(e, value) => {
                          act('PRG_savelog', { log_name: value });
                          setShowOptions(false);
                        }}
                      />
                      {!!has_paper && (
                        <Button
                          fluid
                          content="Show Scanned Paper"
                          onClick={() => {
                            act('ShowPaper');
                            setShowOptions(false);
                          }}
                        />
                      )}
                      {!!has_printer && (
                        <Button
                          fluid
                          content="Print Note"
                          onClick={(e, note) => {
                            act('PrintNote', { print: note });
                            setShowOptions(false);
                          }}
                        />
                      )}
                    </Stack>
                  </div>
                )) ||
                null
              }
            >
              <Button
                icon="cog"
                content="File Options"
                ml={0.5}
                onClick={() => {
                  setShowOptions(!showOptions);
                }}
              />
            </Popper>
          }
          fill
          fitted
        >
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
