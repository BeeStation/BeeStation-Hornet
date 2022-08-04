import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Collapsible, BlockQuote } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';

export const TicketBrowser = (props, context) => {
  const { data } = useBackend(context);
  const {
    unclaimed_tickets = [],
    open_tickets = [],
    closed_tickets = [],
    resolved_tickets = [],
    admin_ckey,
    is_admin_panel,
  } = data;
  return (
    <Window
      theme="admin"
      width={720}
      height={480}>
      <Window.Content scrollable>
        <Section
          title={
            <Table>
              <Table.Row>
                <Table.Cell
                  inline>
                  {is_admin_panel ? "Administrator" : "Mentor"}: {admin_ckey}
                </Table.Cell>
              </Table.Row>
            </Table>
          } />
        <Section>
          <TicketMenu
            ticket_list={unclaimed_tickets}
            name={"Unclaimed Tickets"}
            actions={[["claim", "good"], ["reject", "bad"]]}
            admin_actions={[["flw", "blue"], ["ic", "label"], ["mhelp", "label"]]} />
          <TicketMenu
            ticket_list={open_tickets}
            name={"Claimed Tickets"}
            actions={[["claim", "average"],
              ["resolve", "good"],
              ["reject", "bad"], ["close", "label"]]}
            admin_actions={[["flw", "blue"], ["mhelp", "label"],
              ["ic", "label"]]} />
          <TicketMenu
            ticket_list={resolved_tickets}
            name={"Resolved Tickets"}
            actions={[["reopen", "good"]]}
            admin_actions={[["flw", "blue"]]} />
          <TicketMenu
            ticket_list={closed_tickets}
            name={"Closed Tickets"}
            actions={[["reopen", "good"]]}
            admin_actions={[["flw", "blue"]]} />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketMenu = (props, context) => {
  const {
    ticket_list,
    name,
    actions = [],
    admin_actions = [],
  } = props;
  const { act } = useBackend(context);
  return (
    <Section
      title={name}>
      <Table>
        {ticket_list.map(ticket => (
          <Section independent
            key={ticket.name} >
            <Table.Row>
              <Table.Cell
                bold
                collapsing>
                <Button
                  color="transparent"
                  onClick={() => act("view", {
                    id: ticket.id,
                  })}>
                  <u>
                    {(ticket.is_admin_type ? "" : "[MENTOR] ") + "#" + ticket.id}
                  </u>
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  color={ticket.disconnected ? "bad" : "transparent"}
                  onClick={() => act("pm", {
                    id: ticket.id,
                  })}>
                  <u>
                    {ticket.initiator_key_name} \
                    {ticket.disconnected ? "[DC]" : ""}
                  </u>
                </Button>
              </Table.Cell>
              {(ticket.is_admin_type ? actions.concat(admin_actions) : actions.concat([["ahelp", "label"]]))
                .map(action => (
                  <Table.Cell
                    key={action[0]}
                    collapsing>
                    <Button
                      content={capitalize(action[0])}
                      onClick={() => act(action[0], {
                        id: ticket.id,
                      })}
                      color={action[1]} />
                  </Table.Cell>
                ))}
            </Table.Row>
            <BlockQuote>
              {ticket.name}
            </BlockQuote>
            <Box
              color={ticket.claimed_key_name ? 'good' : 'bad'}>
              {ticket.claimed_key_name
                ? ticket.state < 3
                  ? 'Claimed by ' + ticket.claimed_key_name
                  : ticket.state === 3
                    ? 'Closed by ' + ticket.claimed_key_name
                    : 'Resolved by ' + ticket.claimed_key_name
                : 'UNCLAIMED'}
            </Box>
          </Section>
        ))}
      </Table>
    </Section>
  );
};
