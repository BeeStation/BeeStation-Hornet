import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

export const CloningConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { useRecords, hasAutoprocess, autoprocess, temp, scanTemp, scannerLocked, hasOccupant, recordsLength, experimental } =
    data;
  const lacksMachine = data.lacksMachine || [];
  const diskData = data.diskData || [];
  const records = data.records || [];
  return (
    <Window width="400" height="600" resizable>
      <Window.Content scrollable>
        <Section>
          <Section title="Cloning Pod Status">
            <Box backgroundColor="#40638a" p="1px">
              <Box backgroundColor="black" color="white" p="5px">
                {temp}
              </Box>
            </Box>
          </Section>
          {!lacksMachine.length ? (
            <Section title="Scanner Functions">
              <Box backgroundColor="#40638a" p="1px">
                <Box backgroundColor="black" color="white" p="5px">
                  {scanTemp}
                </Box>
              </Box>
              <br />
              <Button content={'Full Scan'} icon={'search'} disabled={!hasOccupant} onClick={() => act('scan')} />
              {!experimental ? (
                <Button content={'Body only'} disabled={!hasOccupant} icon={'search'} onClick={() => act('scan_body_only')} />
              ) : (
                ''
              )}
              <Button
                content={scannerLocked ? 'Unlock Scanner' : 'Lock Scanner'}
                icon={scannerLocked ? 'lock' : 'lock-open'}
                disabled={!hasOccupant && !scannerLocked}
                onClick={() => act('toggle_lock')}
              />
            </Section>
          ) : (
            <Section title="Modules">
              {lacksMachine.map((machine) => (
                <Box key={machine} color="red">
                  {machine}
                  <br />
                </Box>
              ))}
            </Section>
          )}
          {useRecords ? (
            <Section>
              <Section title="Database Functions">
                <NoticeBox>
                  <Collapsible title={recordsLength}>
                    <h2>Current Records: </h2>
                    {records.map((record) => (
                      <Section backgroundColor="#191919" color="white" key={record}>
                        <Collapsible
                          title={
                            record['name'] +
                            (record['body_only'] ? ' (Body Only)' : record['last_death'] < 0 ? ' (Presaved)' : '')
                          }
                          color={record['body_only'] ? 'yellow' : record['last_death'] < 0 ? 'green' : 'blue'}>
                          <div
                            key={record['name']}
                            style={{
                              'word-break': 'break-all',
                            }}>
                            Scan ID {record['id']}
                            <br />
                            <Button
                              content="Clone"
                              icon="power-off"
                              disabled={!record['body_only'] && record['last_death'] < 0 && !experimental}
                              onClick={() =>
                                act('clone', {
                                  target: record['id'],
                                })
                              }
                            />
                            <Button
                              content="Delete Record"
                              icon="user-slash"
                              onClick={() =>
                                act('delrecord', {
                                  target: record['id'],
                                })
                              }
                            />
                            <Button
                              content="Save to Disk"
                              icon="upload"
                              disabled={diskData.length === 0}
                              onClick={() =>
                                act('save', {
                                  target: record['id'],
                                })
                              }
                            />
                            <br />
                            {record['damages'] ? (
                              <Fragment>
                                Health Implant Data
                                <br />
                                <small>
                                  Oxygen Deprivation Damage:
                                  <br />
                                  <ProgressBar color="blue" value={record['damages']['oxy'] / 100} />
                                  Fire Damage:
                                  <br />
                                  <ProgressBar color="orange" value={record['damages']['burn'] / 100} />
                                  Toxin Damage:
                                  <br />
                                  <ProgressBar color="green" value={record['damages']['tox'] / 100} />
                                  Brute Damage:
                                  <br />
                                  <ProgressBar color="red" value={record['damages']['brute'] / 100} />
                                </small>
                                <br />
                              </Fragment>
                            ) : (
                              <Fragment>
                                Health implant data not available
                                <br />
                              </Fragment>
                            )}
                            Unique Identifier:
                            <br />
                            {record['UI']}
                            <br />
                            Unique Enzymes:
                            <br />
                            {record['UE']}
                            <br />
                            Blood Type:
                            <br />
                            {record['blood_type']}
                            <br />
                          </div>
                        </Collapsible>
                      </Section>
                    ))}
                  </Collapsible>
                </NoticeBox>
              </Section>
              <Section
                title="Disk"
                buttons={
                  <Box>
                    <Button content="Load" icon="download" disabled={!diskData['name']} onClick={() => act('load')} />
                    <Button content="Eject Disk" icon="eject" disabled={diskData.length === 0} onClick={() => act('eject')} />
                  </Box>
                }>
                {diskData.length !== 0 ? (
                  <Collapsible
                    title={
                      diskData['name']
                        ? diskData['name'] +
                        (diskData['body_only'] ? ' (Body Only)' : diskData['last_death'] < 0 ? ' (Presaved)' : '')
                        : 'Empty Disk'
                    }
                    color={
                      diskData['name']
                        ? diskData['body_only']
                          ? 'yellow'
                          : diskData['last_death'] < 0
                            ? 'green'
                            : 'blue'
                        : 'grey'
                    }>
                    {diskData['id'] ? (
                      <Box
                        style={{
                          'word-break': 'break-all',
                        }}>
                        ID: {diskData['id']}
                        <br />
                        UI: {diskData['UI']}
                        <br />
                        UE: {diskData['UE']}
                        <br />
                        Blood Type: {diskData['blood_type']}
                        <br />
                      </Box>
                    ) : (
                      'No Data'
                    )}
                  </Collapsible>
                ) : (
                  'No Disk'
                )}
              </Section>
            </Section>
          ) : null}
        </Section>
      </Window.Content>
    </Window>
  );
};
