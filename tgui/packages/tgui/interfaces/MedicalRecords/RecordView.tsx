import { NoteKeeper } from './NoteKeeper';
import { Stack, Section, NoticeBox, Box, LabeledList, Button, RestrictedInput } from 'tgui/components';
import { CharacterPreview } from '../common/CharacterPreview';
import { getMedicalRecord, getQuirkStrings } from './helpers';
import { useBackend } from '../../backend';
import { PHYSICALSTATUS2COLOR, PHYSICALSTATUS2DESC, PHYSICALSTATUS2ICON, MENTALSTATUS2COLOR, MENTALSTATUS2DESC, MENTALSTATUS2ICON } from './constants';
import { MedicalRecordData } from './types';
import { EditableText } from '../common/EditableText';

/** Views a selected record. */
export const MedicalRecordView = (props, context) => {
  const foundRecord = getMedicalRecord(context);
  if (!foundRecord) return <NoticeBox>No record selected.</NoticeBox>;

  const { act, data } = useBackend<MedicalRecordData>(context);
  const { character_preview_view, physical_statuses, mental_statuses } = data;

  const { min_age, max_age } = data;

  const {
    age,
    blood_type,
    record_ref,
    dna,
    gender,
    major_disabilities,
    minor_disabilities,
    physical_status,
    mental_status,
    name,
    quirk_notes,
    rank,
    species,
  } = foundRecord;

  const minor_disabilities_array = getQuirkStrings(minor_disabilities);
  const major_disabilities_array = getQuirkStrings(major_disabilities);
  const quirk_notes_array = getQuirkStrings(quirk_notes);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item>
            <CharacterPreview height="100%" id={character_preview_view} />
          </Stack.Item>
          <Stack.Item grow>
            <NoteKeeper />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          buttons={
            <Button.Confirm
              content="Anonymize"
              icon="mask"
              onClick={() => act('anonymize_record', { record_ref: record_ref })}
              tooltip="Anonymize record data."
            />
          }
          fill
          scrollable
          title={name}
          wrap>
          <LabeledList>
            <LabeledList.Item label="Name">
              <Box>{name}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Job">
              <Box>{rank}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <RestrictedInput
                minValue={min_age}
                maxValue={max_age}
                onEnter={(event, value) =>
                  act('edit_field', {
                    field: 'age',
                    ref: record_ref,
                    value: value,
                  })
                }
                value={age}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Species">
              <EditableText field="species" target_ref={record_ref} text={species} />
            </LabeledList.Item>
            <LabeledList.Item label="Gender">
              <EditableText field="gender" target_ref={record_ref} text={gender} />
            </LabeledList.Item>
            <LabeledList.Item label="DNA">
              <EditableText color="good" field="dna" target_ref={record_ref} text={dna} />
            </LabeledList.Item>
            <LabeledList.Item color="bad" label="Blood Type">
              <EditableText field="blood_type" target_ref={record_ref} text={blood_type} />
            </LabeledList.Item>
            <LabeledList.Item
              buttons={physical_statuses.map((button, index) => {
                const isSelected = button === physical_status;
                return (
                  <Button
                    color={isSelected ? PHYSICALSTATUS2COLOR[button] : 'grey'}
                    height={'1.75rem'}
                    icon={PHYSICALSTATUS2ICON[button]}
                    key={index}
                    onClick={() =>
                      act('set_physical_status', {
                        record_ref: record_ref,
                        physical_status: button,
                      })
                    }
                    textAlign="center"
                    tooltip={PHYSICALSTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start"
                    width={!isSelected ? '3.0rem' : 3.0}>
                    {button[0]}
                  </Button>
                );
              })}
              label="Physical Status">
              <Box color={PHYSICALSTATUS2COLOR[physical_status]}>{physical_status}</Box>
            </LabeledList.Item>
            <LabeledList.Item
              buttons={mental_statuses.map((button, index) => {
                const isSelected = button === mental_status;
                return (
                  <Button
                    color={isSelected ? MENTALSTATUS2COLOR[button] : 'grey'}
                    height={'1.75rem'}
                    icon={MENTALSTATUS2ICON[button]}
                    key={index}
                    onClick={() =>
                      act('set_mental_status', {
                        record_ref: record_ref,
                        mental_status: button,
                      })
                    }
                    textAlign="center"
                    tooltip={MENTALSTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start"
                    width={!isSelected ? '3.0rem' : 3.0}>
                    {button[0]}
                  </Button>
                );
              })}
              label="Mental Status">
              <Box color={MENTALSTATUS2COLOR[mental_status]}>{mental_status}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Minor Disabilities">
              {minor_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Major Disabilities">
              {major_disabilities_array.map((disability, index) => (
                <Box key={index}>&#8226; {disability}</Box>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Quirks">
              {quirk_notes_array.map((quirk, index) => (
                <Box key={index}>&#8226; {quirk}</Box>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
