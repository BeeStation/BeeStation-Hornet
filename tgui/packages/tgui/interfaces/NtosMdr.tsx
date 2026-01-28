import { useBackend } from '../backend';
import { Box, Button, Section, Table } from '../components';
import { NtosWindow } from '../layouts';
import { MdrContent, MdrData } from './AtmosMdr';
export const NtosMdr = (props) => {
  type MdrDataList = Record<string, MdrData>;

  type Data = {
    mdr_data: MdrDataList;
    selected_mdr_uid: number;
  };

  const { act, data } = useBackend<Data>();
  const { mdr_data, selected_mdr_uid } = data;
  const activeMdr = Object.values(mdr_data).find(
    (mdr) => mdr.uid === selected_mdr_uid,
  );
  return (
    <NtosWindow height={400} width={700}>
      <NtosWindow.Content scrollable>
        {activeMdr ? (
          <Box>
            <Button
              icon="arrow-left"
              onClick={() =>
                act('select_mdr', {
                  select_mdr: null,
                })
              }
            >
              Back
            </Button>
            <MdrContent {...activeMdr} />
          </Box>
        ) : (
          <Section title="Detected Metallic Decay Reactors">
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />
            <Table>
              {Object.values(mdr_data).map((mdr) => {
                return (
                  <Table.Row key={mdr.uid}>
                    <Table.Cell>
                      {`MDR::${mdr.uid} at ${mdr.area}`}
                      <Button
                        icon="arrow-right"
                        onClick={() =>
                          act('select_mdr', {
                            select_mdr: mdr.uid,
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
