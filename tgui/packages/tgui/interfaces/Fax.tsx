import { sortBy } from '../../common/collections';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type FaxData = {
  faxes: FaxInfo[];
  fax_id: string;
  fax_name: string;
  visible: boolean;
  has_paper: string;
  access_additional_faxes: boolean;
  сan_switch_access: boolean;
  additional_faxes_list: AdditionalFaxesList[];
  syndicate_network: boolean;
  syndicate_faxes_list: AdditionalFaxesList[];
  fax_history: FaxHistory[];
};

type FaxInfo = {
  fax_name: string;
  fax_id: string;
  visible: boolean;
  has_paper: boolean;
  syndicate_network: boolean;
};

type AdditionalFaxesList = {
  fax_name: string;
  button_color: string;
};

type FaxHistory = {
  history_type: string;
  history_fax_name: string;
  history_time: string;
};

export const Fax = (props, context) => {
  const { act } = useBackend(context);
  const { data } = useBackend<FaxData>(context);
  const faxes = data.faxes
    ? sortBy((sortFax: FaxInfo) => sortFax.fax_name)(
      data.syndicate_network
        ? data.faxes.filter((filterFax: FaxInfo) => filterFax.visible)
        : data.faxes.filter(
          (filterFax: FaxInfo) =>
            filterFax.visible && !filterFax.syndicate_network
        )
    )
    : [];
  return (
    <Window width={340} height={540}>
      <Window.Content scrollable>
        <Section title="About Fax">
          <LabeledList.Item label="Network name">
            {data.fax_name}
          </LabeledList.Item>
          <LabeledList.Item label="Network ID">{data.fax_id}</LabeledList.Item>
          <LabeledList.Item label="Visible to Network">
            {data.visible ? true : false}
          </LabeledList.Item>
        </Section>
        <Section
          title="Paper"
          buttons={
            <Button
              onClick={() => act('remove')}
              disabled={data.has_paper ? false : true}>
              Remove
            </Button>
          }>
          <LabeledList.Item label="Paper">
            {data.has_paper ? (
              <Box color="green">Paper in tray</Box>
            ) : (
              <Box color="red">No paper</Box>
            )}
          </LabeledList.Item>
        </Section>
        <Section
          title="Send"
          buttons={
            <Button
              color={data.access_additional_faxes ? 'bad' : 'good'}
              onClick={() => act('access_additional_faxes_toggle')}
              disabled={!data.сan_switch_access}
              tooltip="Manage access to the expanded fax list.">
              {data.access_additional_faxes ? 'Logout' : 'Login'}
            </Button>
          }>
          {faxes.length !== 0 ? (
            <Box mt={0.4}>
              {!!data.access_additional_faxes
              && data.additional_faxes_list.map((fax: AdditionalFaxesList) => (
                <Button
                  key={fax.fax_name}
                  title={fax.fax_name}
                  disabled={!data.has_paper}
                  backgroundColor={fax.button_color}
                  onClick={() =>
                    act('send_to_additional_fax', {
                      name: fax.fax_name,
                      color: fax.button_color,
                    })}>
                  {fax.fax_name}
                </Button>
              ))}
              {!!data.syndicate_network
              && data.syndicate_faxes_list.map((fax: AdditionalFaxesList) => (
                <Button
                  key={fax.fax_name}
                  title={fax.fax_name}
                  disabled={!data.has_paper}
                  backgroundColor={fax.button_color}
                  onClick={() =>
                    act('send_to_additional_fax', {
                      name: fax.fax_name,
                      color: fax.button_color,
                    })}>
                  {fax.fax_name}
                </Button>
              ))}
              {faxes.map((fax: FaxInfo) => (
                <Button
                  key={fax.fax_id}
                  title={fax.fax_name}
                  disabled={!data.has_paper}
                  color={fax.syndicate_network ? 'red' : 'blue'}
                  onClick={() =>
                    act('send', {
                      id: fax.fax_id,
                      name: fax.fax_name,
                    })}>
                  {fax.fax_name}
                </Button>
              ))}
            </Box>
          ) : (
            "The fax couldn't detect any other faxes on the network."
          )}
        </Section>
        <Section
          title="History"
          buttons={
            <Button
              onClick={() => act('history_clear')}
              disabled={data.fax_history ? false : true}>
              Clear
            </Button>
          }>
          <Table>
            <Table.Cell>
              {data.fax_history !== null
                ? data.fax_history.map((history: FaxHistory) => (
                  <Table.Row key={history.history_type}>
                    {
                      <Box
                        color={
                          history.history_type === 'Send' ? 'Green' : 'Red'
                        }>
                        {history.history_type}
                      </Box>
                    }
                    {history.history_fax_name} - {history.history_time}
                  </Table.Row>
                ))
                : null}
            </Table.Cell>
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
