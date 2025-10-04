import { multiline } from 'common/string';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  BlockQuote,
  Box,
  Button,
  Icon,
  LabeledList,
  Section,
  Tabs,
  TextArea,
  Tooltip,
} from 'tgui/components';

import { getMedicalRecord } from './helpers';
import { MedicalNote, MedicalRecordData } from './types';

/** Small section for adding notes. Passes a ref and note to Byond. */
export const NoteKeeper = (props) => {
  const foundRecord = getMedicalRecord();
  if (!foundRecord) return <> </>;

  const { act } = useBackend<MedicalRecordData>();
  const { record_ref } = foundRecord;

  const [selectedNote, setSelectedNote] = useLocalState<
    MedicalNote | undefined
  >('selectedNote', undefined);

  const [writing, setWriting] = useLocalState('note', false);

  const addNote = (event, value: string) => {
    act('add_note', {
      record_ref: record_ref,
      content: value,
    });
    setWriting(false);
  };

  const deleteNote = () => {
    if (!selectedNote) return;
    act('delete_note', {
      record_ref: record_ref,
      note_ref: selectedNote.note_ref,
    });
    setSelectedNote(undefined);
  };

  return (
    <Section buttons={<NoteTabs />} fill scrollable title="Notes">
      {writing && (
        <TextArea
          height="100%"
          maxLength={1024}
          onEnter={addNote}
          onEscape={() => setWriting(false)}
        />
      )}

      {!!selectedNote && (
        <>
          <LabeledList>
            <LabeledList.Item
              label="Author"
              buttons={<Button color="bad" icon="trash" onClick={deleteNote} />}
            >
              {selectedNote.author}
            </LabeledList.Item>
            <LabeledList.Item label="Time">
              {selectedNote.time}
            </LabeledList.Item>
          </LabeledList>
          <Box color="label" mb={1} mt={1}>
            Content:
          </Box>
          <BlockQuote wrap>{selectedNote.content}</BlockQuote>
        </>
      )}
    </Section>
  );
};

/** Displays the notes with an add tab next to. */
const NoteTabs = (props) => {
  const foundRecord = getMedicalRecord();
  if (!foundRecord) return <> </>;
  const { medical_notes } = foundRecord;

  const [selectedNote, setSelectedNote] = useLocalState<
    MedicalNote | undefined
  >('selectedNote', undefined);
  const [writing, setWriting] = useLocalState('note', false);

  /** Selects or deselects a note. */
  const setNote = (note: MedicalNote) => {
    if (selectedNote?.note_ref === note.note_ref) {
      setSelectedNote(undefined);
    } else {
      setSelectedNote(note);
    }
  };

  /** Sets the note to writing mode. */
  const composeNew = () => {
    setWriting(true);
    setSelectedNote(undefined);
  };

  return (
    <Tabs>
      {medical_notes !== null
        ? medical_notes.map((note, index) => (
            <Tabs.Tab
              key={index}
              label={index + 1}
              onClick={() => setNote(note)}
              selected={selectedNote?.note_ref === note.note_ref}
            >
              {index + 1}
            </Tabs.Tab>
          ))
        : null}
      <Tooltip
        content={multiline`Add a new note. Press enter or escape to exit view.`}
        position="bottom"
      >
        <Tabs.Tab onClick={composeNew} selected={writing}>
          <Icon name="plus" /> New
        </Tabs.Tab>
      </Tooltip>
    </Tabs>
  );
};
