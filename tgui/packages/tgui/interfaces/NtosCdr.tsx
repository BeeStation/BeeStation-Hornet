import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';
import { CdrContent, CdrData } from './AtmosCdr/CdrContent';

export const NtosCdr = (props) => {
  type CdrDataList = Record<string, CdrData>;

  type Data = {
    cdr_data: CdrDataList;
    selected_cdr_uid: number;
  };

  const { act, data } = useBackend<Data>();
  const { cdr_data, selected_cdr_uid } = data;
  const activeCdr = Object.values(cdr_data).find(
    (cdr) => cdr.uid === selected_cdr_uid,
  );
  return (
    <NtosWindow height={400} width={700}>
      <NtosWindow.Content scrollable>
        {activeCdr ? (
          <Box>
            <Button
              icon="arrow-left"
              onClick={() =>
                act('select_cdr', {
                  select_cdr: null,
                })
              }
            >
              Back
            </Button>
            <CdrContent {...activeCdr} />
          </Box>
        ) : (
          <Section title="Detected Condensate Decay Reactors">
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />
            <Table>
              {Object.values(cdr_data).map((cdr) => {
                return (
                  <Table.Row key={cdr.uid}>
                    <Table.Cell>
                      {`CDR::${cdr.uid} at ${cdr.area}`}
                      <Button
                        icon="arrow-right"
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
