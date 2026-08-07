import { useState } from 'react';

import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Table } from '../components';
import { NtosWindow } from '../layouts';
import { RbmkContent, RbmkData } from './Rbmk';

type NtosRbmkData = RbmkData & { focus_uid?: number };

export const NtosRbmk = (props) => {
  const { act, data } = useBackend<NtosRbmkData>();
  const { rbmk_data, focus_uid } = data;
  const [activeUID, setActiveUID] = useState(0);
  const activeReactor = rbmk_data.find((reactor) => reactor.uid === activeUID);

  return (
    <NtosWindow height={400} width={700}>
      <NtosWindow.Content>
        {activeReactor ? (
          <RbmkContent
            {...activeReactor}
            sectionButton={
              <Button icon="arrow-left" onClick={() => setActiveUID(0)}>
                Back
              </Button>
            }
          />
        ) : (
          <Section
            title="Detected Nuclear Reactors"
            buttons={
              <Button
                icon="sync"
                content="Refresh"
                onClick={() => act('PRG_refresh')}
              />
            }
          >
            <Table>
              {rbmk_data.map((reactor) => (
                <Table.Row key={reactor.uid}>
                  <Table.Cell>
                    {reactor.uid + '. ' + reactor.area_name}
                  </Table.Cell>
                  <Table.Cell collapsing color="label">
                    Integrity:
                  </Table.Cell>
                  <Table.Cell collapsing width="120px">
                    <ProgressBar
                      value={reactor.integrity / 100}
                      ranges={{
                        good: [0.9, Infinity],
                        average: [0.5, 0.9],
                        bad: [-Infinity, 0.5],
                      }}
                    />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="bell"
                      color={focus_uid === reactor.uid && 'yellow'}
                      onClick={() =>
                        act('PRG_focus', { focus_uid: reactor.uid })
                      }
                    />
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      content="Details"
                      onClick={() => setActiveUID(reactor.uid)}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
