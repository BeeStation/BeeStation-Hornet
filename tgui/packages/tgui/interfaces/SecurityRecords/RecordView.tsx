import { useBackend, useLocalState } from 'tgui/backend';
import { Box, Button, LabeledList, NoticeBox, RestrictedInput, Section, Stack, Table } from 'tgui/components';
import { CharacterPreview } from '../common/CharacterPreview';
import { EditableText } from '../common/EditableText';
import { CrimeWatcher } from './CrimeWatcher';
import { RecordPrint } from './RecordPrint';
import { CRIMESTATUS2COLOR, CRIMESTATUS2DESC } from './constants';
import { getSecurityRecord } from './helpers';
import { SecurityRecordsData } from './types';

/** Views a selected record. */
export const SecurityRecordView = (props, context) => {
  const foundRecord = getSecurityRecord(context);
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { data } = useBackend<SecurityRecordsData>(context);
  const [open] = useLocalState<boolean>(context, 'printOpen', false);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <CharacterPreview height="100%" id={data.character_preview_view} />
          </Stack.Item>
          <Stack.Item grow>
            <CrimeWatcher />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>{open ? <RecordPrint /> : <RecordInfo />}</Stack.Item>
    </Stack>
  );
};

const RecordInfo = (props, context) => {
  const foundRecord = getSecurityRecord(context);
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { act, data } = useBackend<SecurityRecordsData>(context);
  const { available_statuses } = data;
  const [open, setOpen] = useLocalState<boolean>(context, 'printOpen', false);

  const { age, record_ref, crimes, fingerprint, gender, name, security_note, rank, species, wanted_status } = foundRecord;

  const { min_age, max_age } = data;

  const hasValidCrimes = !!crimes.find((crime) => !!crime.valid);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack>
              <Stack.Item>
                <Button height="1.7rem" icon="print" onClick={() => setOpen(true)} tooltip="Print a rapsheet or poster.">
                  Print
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  content="Delete"
                  icon="trash"
                  onClick={() => act('delete_record', { record_ref: record_ref })}
                  tooltip="Delete record data."
                />
              </Stack.Item>
            </Stack>
          }
          fill
          title={<Table.Cell color={CRIMESTATUS2COLOR[wanted_status]}>{name}</Table.Cell>}
          wrap>
          <LabeledList>
            <LabeledList.Item
              buttons={available_statuses.map((button, index) => {
                const isSelected = button === wanted_status;
                return (
                  <Button
                    color={isSelected ? CRIMESTATUS2COLOR[button] : 'grey'}
                    disabled={button === 'Arrest' && !hasValidCrimes}
                    icon={isSelected ? 'check' : ''}
                    key={index}
                    onClick={() =>
                      act('set_wanted', {
                        record_ref: record_ref,
                        status: button,
                      })
                    }
                    pl={!isSelected ? '1.8rem' : 1}
                    tooltip={CRIMESTATUS2DESC[button] || ''}
                    tooltipPosition="bottom-start">
                    {button[0]}
                  </Button>
                );
              })}
              label="Status">
              <Box color={CRIMESTATUS2COLOR[wanted_status]}>{wanted_status}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow={2}>
        <Section fill scrollable>
          <LabeledList>
            <LabeledList.Item label="Name">
              <EditableText field="name" target_ref={record_ref} text={name} />
            </LabeledList.Item>
            <LabeledList.Item label="Job">
              <EditableText field="rank" target_ref={record_ref} text={rank} />
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              <RestrictedInput
                minValue={min_age}
                maxValue={max_age}
                onEnter={(event, value) =>
                  act('edit_field', {
                    record_ref: record_ref,
                    field: 'age',
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
            <LabeledList.Item color="good" label="Fingerprint">
              <EditableText color="good" field="fingerprint" target_ref={record_ref} text={fingerprint} />
            </LabeledList.Item>
            <LabeledList.Item label="Note">
              <EditableText field="security_note" target_ref={record_ref} text={security_note} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
