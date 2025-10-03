import { filter, sortBy } from 'common/collections';
import { useBackend, useLocalState } from 'tgui/backend';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui/components';

import { JOB2ICON } from '../common/JobToIcon';
import { CRIMESTATUS2COLOR } from './constants';
import { isRecordMatch } from './helpers';
import { SecurityRecord, SecurityRecordsData } from './types';

/** Tabs on left, with search bar */
export const SecurityRecordTabs = (props) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { higher_access, records = [] } = data;

  const errorMessage = !records.length
    ? 'No records found.'
    : 'No match. Refine your search.';

  const [search, setSearch] = useLocalState('search', '');

  const sorted = sortBy(
    filter(records, (record) => isRecordMatch(record, search)),
    (record) => record.name,
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Input
          fluid
          placeholder="Name/Job/Fingerprints"
          onInput={(event, value) => setSearch(value)}
        />
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Tabs vertical>
            {!sorted.length ? (
              <NoticeBox>{errorMessage}</NoticeBox>
            ) : (
              sorted.map((record, index) => (
                <CrewTab record={record} key={index} />
              ))
            )}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item align="center">
        <Stack fill>
          <Stack.Item>
            <Button
              disabled
              icon="plus"
              tooltip="Add new records by inserting a 1 by 1 meter photo into the terminal. You do not need this screen open."
            >
              Create
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              content="Purge"
              disabled={!higher_access}
              icon="trash"
              onClick={() => act('purge_records')}
              tooltip="Wipe criminal record data."
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

/** Individual record */
const CrewTab = (props: { record: SecurityRecord }) => {
  const [selectedRecord, setSelectedRecord] = useLocalState<
    SecurityRecord | undefined
  >('securityRecord', undefined);

  const { act, data } = useBackend<SecurityRecordsData>();
  const { character_preview_view } = data;
  const { record } = props;
  const { record_ref, name, rank, wanted_status } = record;

  /** Chooses a record */
  const selectRecord = (record: SecurityRecord) => {
    if (selectedRecord?.record_ref === record_ref) {
      setSelectedRecord(undefined);
    } else {
      setSelectedRecord(record);
      act('view_record', {
        character_preview_view: character_preview_view,
        record_ref: record_ref,
      });
    }
  };

  const isSelected = selectedRecord?.record_ref === record_ref;

  return (
    <Tabs.Tab
      className="candystripe"
      label={record.name}
      onClick={() => selectRecord(record)}
      selected={isSelected}
    >
      <Box bold={isSelected} color={CRIMESTATUS2COLOR[wanted_status]} wrap>
        <Icon name={JOB2ICON[rank] || 'question'} /> {name}
      </Box>
    </Tabs.Tab>
  );
};
