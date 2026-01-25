import { useBackend, useLocalState } from 'tgui/backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  RestrictedInput,
  Section,
  Stack,
  Table,
} from 'tgui/components';

import { CharacterPreview } from '../common/CharacterPreview';
import { EditableText } from '../common/EditableText';
import { CRIMESTATUS2COLOR, CRIMESTATUS2DESC } from './constants';
import { CrimeWatcher } from './CrimeWatcher';
import { getSecurityRecord } from './helpers';
import { RecordPrint } from './RecordPrint';
import { SecurityRecordsData } from './types';

/** Views a selected record. */
export const SecurityRecordView = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { data } = useBackend<SecurityRecordsData>();
  const [open] = useLocalState<boolean>('printOpen', false);

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

const RecordInfo = (props) => {
  const foundRecord = getSecurityRecord();
  if (!foundRecord) return <NoticeBox>Nothing selected.</NoticeBox>;

  const { act, data } = useBackend<SecurityRecordsData>();
  const { available_statuses, is_silicon } = data;
  const [open, setOpen] = useLocalState<boolean>('printOpen', false);

  const {
    age,
    record_ref,
    crimes,
    fingerprint,
    gender,
    name,
    security_note,
    rank,
    species,
    wanted_status,
  } = foundRecord;

  const { min_age, max_age } = data;

  const hasValidCrimes = !!crimes.find((crime) => !!crime.valid);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  disabled={is_silicon}
                  height="1.7rem"
                  icon="print"
                  onClick={() => setOpen(true)}
                  tooltip="Print a rapsheet or poster."
                >
                  Print
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  disabled={is_silicon}
                  content="Delete"
                  icon="trash"
                  onClick={() =>
                    act('delete_record', { record_ref: record_ref })
                  }
                  tooltip="Delete record data."
                />
              </Stack.Item>
            </Stack>
          }
          fill
          title={
            <Table.Cell color={CRIMESTATUS2COLOR[wanted_status]}>
              {name}
            </Table.Cell>
          }
          wrap
        >
          <LabeledList>
            <LabeledList.Item
              buttons={available_statuses.map((button, index) => {
                const isSelected = button === wanted_status;
                return (
                  <Button
                    color={isSelected ? CRIMESTATUS2COLOR[button] : 'grey'}
                    disabled={
                      (button === 'Arrest' && !hasValidCrimes) || is_silicon
                    }
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
                    tooltipPosition="bottom-start"
                  >
                    {button[0]}
                  </Button>
                );
              })}
              label="Status"
            >
              <Box color={CRIMESTATUS2COLOR[wanted_status]}>
                {wanted_status}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow={2}>
        <Section fill scrollable>
          <LabeledList>
            <LabeledList.Item label="Name">
              {is_silicon ? (
                name
              ) : (
                <EditableText
                  field="name"
                  target_ref={record_ref}
                  text={name}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Job">
              {is_silicon ? (
                rank
              ) : (
                <EditableText
                  field="rank"
                  target_ref={record_ref}
                  text={rank}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Age">
              {is_silicon ? (
                age
              ) : (
                <RestrictedInput
                  minValue={min_age}
                  maxValue={max_age}
                  onChange={(_, value) =>
                    act('edit_field', {
                      record_ref: record_ref,
                      field: 'age',
                      value: value,
                    })
                  }
                  value={age}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Species">
              {is_silicon ? (
                species
              ) : (
                <EditableText
                  field="species"
                  target_ref={record_ref}
                  text={species}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Gender">
              {is_silicon ? (
                gender
              ) : (
                <EditableText
                  field="gender"
                  target_ref={record_ref}
                  text={gender}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item color="good" label="Fingerprint">
              {is_silicon ? (
                fingerprint
              ) : (
                <EditableText
                  color="good"
                  field="fingerprint"
                  target_ref={record_ref}
                  text={fingerprint}
                />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Note">
              {is_silicon ? (
                security_note
              ) : (
                <EditableText
                  field="security_note"
                  target_ref={record_ref}
                  text={security_note}
                />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
