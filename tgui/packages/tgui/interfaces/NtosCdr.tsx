import { useState } from 'react';
import { Box, Button, ProgressBar, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { CdrContent, CdrData } from './AtmosCdr/CdrContent';
import { CdrHelpMenu } from './AtmosCdr/CdrHelpMenu';

export const NtosCdr = (props) => {
  type CdrDataList = Record<string, CdrData>;

  type Data = {
    cdr_data: CdrDataList;
    selected_cdr_uid: number;
  };

  const { act, data } = useBackend<Data>();
  const { cdr_data, selected_cdr_uid } = data;
  const [helpMenuOpen, setHelpMenuOpen] = useState(false);
  const activeCdr = Object.values(cdr_data).find(
    (cdr) => cdr.uid === selected_cdr_uid,
  );
  // height={800} width={460}
  return (
    <NtosWindow height={activeCdr ? 750 : 400} width={activeCdr ? 460 : 700}>
      <NtosWindow.Content scrollable>
        {activeCdr ? (
          <Box>
            <Section
              fitted
              title={`${activeCdr.uid}. at ${activeCdr.area}`}
              buttons={
              <Box>
                <Button
                  icon="arrow-left"
                  onClick={() => act('select_cdr', { select_cdr: null })}>
                  Back
                </Button>
                <Button
                  icon="question"
                  selected={helpMenuOpen}
                  onClick={() => setHelpMenuOpen(!helpMenuOpen)}>
                  Help
                </Button>
              </Box>} />
            {helpMenuOpen ? <CdrHelpMenu /> : <CdrContent {...activeCdr} />}
          </Box>
        ) : (
          <Section title="Detected Condensate Decay Reactors" buttons={
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />}>
            <Table>
              {Object.values(cdr_data).map((cdr) => {
                const cdrOverhead = ((cdr.core_instability - cdr.core_stability) / cdr.core_instability) * 100;
                return (
                  <Table.Row key={cdr.uid}>
                    <Table.Cell>
                    {`${cdr.uid}. ${cdr.area}`}
                    </Table.Cell>
                    <Table.Cell color="label">
                      Overhead:
                    </Table.Cell>
                    <Table.Cell width={5}>
                      <ProgressBar
                        maxValue={100}
                        minValue={0}
                        value={cdr.core_instability === cdr.core_stability ? 0 : cdrOverhead} // if they're both 0 then that means the CDR is inactive and the overhead will not-a-number
                        ranges={{
                          good: [25, Infinity],
                          average: [-25, 25],
                          bad: [-Infinity, -25],
                        }} />
                    </Table.Cell>
                    <Table.Cell color="label">
                      Integrity:
                    </Table.Cell>
                    <Table.Cell width={10}>
                      <ProgressBar
                        minValue={0}
                        maxValue={cdr.max_core_health}
                        value={cdr.core_health}
                        ranges={{
                          good: [cdr.max_core_health * 0.75, Infinity],
                          average: [cdr.max_core_health * 0.25, cdr.max_core_health * 0.75],
                          bad: [-Infinity, cdr.max_core_health * 0.25],
                        }}
                      />
                    </Table.Cell>
                    <Table.Cell>
                      <Button
                        content={"Details"}
                        onClick={() =>
                          act('select_cdr', {
                            select_cdr: cdr.uid,
                          })
                        }
                      />
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
