import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend, useLocalState } from 'tgui/backend';
import { Stack, Input, Section, Tabs, NoticeBox, Box, Icon, Button } from 'tgui/components';
import { JOB2ICON } from '../common/JobToIcon';
import { isRecordMatch } from '../SecurityRecords/helpers';
import { MedicalRecord, MedicalRecordData } from './types';

/** Displays all found records. */
export const MedicalRecordTabs = (props, context) => {
  const { act, data } = useBackend<MedicalRecordData>(context);
  const { records = [] } = data;

  const errorMessage = !records.length ? 'No records found.' : 'No match. Refine your search.';

  const [search, setSearch] = useLocalState(context, 'search', '');

  const sorted: MedicalRecord[] = flow([
    filter((record: MedicalRecord) => isRecordMatch(record, search)),
    sortBy((record: MedicalRecord) => record.name?.toLowerCase()),
  ])(records);

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input fluid onInput={(_, value) => setSearch(value)} placeholder="Name/Job/DNA" />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Tabs vertical>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              sorted.map((record, index) => <CrewTab key={index} record={record} />)
            )}
          </Tabs>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

/** Individual crew tab */
const CrewTab = (props: { record: MedicalRecord }, context) => {
  const [selectedRecord, setSelectedRecord] = useLocalState<MedicalRecord | undefined>(context, 'medicalRecord', undefined);

  const { act, data } = useBackend<MedicalRecordData>(context);
  const { character_preview_view } = data;
  const { record } = props;
  const { record_ref, name, rank } = record;

  /** Sets the record to preview */
  const selectRecord = (record: MedicalRecord) => {
    if (selectedRecord?.record_ref === record_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', { character_preview_view: character_preview_view, record_ref: record_ref });
    }
  };

  return (
    <Tabs.Tab
      className="candystripe"
      label={name}
      onClick={() => selectRecord(record)}
      selected={selectedRecord?.record_ref === record_ref}>
      <Box wrap>
        <Icon name={JOB2ICON[rank] || 'question'} /> {name}
      </Box>
    </Tabs.Tab>
  );
};
