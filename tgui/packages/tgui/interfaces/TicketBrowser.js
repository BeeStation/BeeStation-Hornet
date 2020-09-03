import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Collapsible, BlockQuote } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';
import { Fragment } from 'inferno';

export const TicketBrowser = (props, context) => {
  const { data } = useBackend(context);
  const {
    unclaimed_tickets = [],
    open_tickets = [],
    closed_tickets = [],
    resolved_tickets = [],
    admin_ckey,
  } = data;
  return (
    <Window
      theme="admin"
      resizable>
      <Window.Content scrollable>
        <Section
          title={
            <Table>
              <Table.Row>
                <Table.Cell
                  inline>
                  Administrator : {admin_ckey}
                </Table.Cell>
              </Table.Row>
            </Table>
          } />
        <Section>
          <TicketMenu
            ticket_list={unclaimed_tickets}
            name={"Unclaimed Tickets"}
            actions={[["flw", "blue"], ["claim", "good"], ["reject", "bad"],
              ["ic", "label"]]}
              show_xfer = {1}/>
          <TicketMenu //XFER commands have shifted to the TM itself, controlled by the show_xfer arg.
            ticket_list={open_tickets}
            name={"Claimed Tickets"}
            actions={[["flw", "blue"], ["claim", "average"],
              ["resolve", "good"],
              ["reject", "bad"], ["close", "label"],
              ["ic", "label"]]}
            show_xfer = {1}/>
          <TicketMenu
            ticket_list={resolved_tickets}
            name={"Resolved Tickets"}
            actions={[["flw", "blue"], ["reopen", "good"]]} />
          <TicketMenu
            ticket_list={closed_tickets}
            name={"Closed Tickets"}
            actions={[["flw", "blue"], ["reopen", "good"]]} />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketMenu = (props, context) => {
  const {
    ticket_list,
    name,
    show_xfer,
    actions = [],
  } = props;
  const { act } = useBackend(context);
  return (
    <Section
      title={name}>
      <Table>
        {ticket_list.map(ticket => (
          <Section
            key={ticket.name} >
            <Table.Row>
              <Table.Cell
                bold
                collapsing>
                <Button
                  color={ticket.tier == "admin" ? "bad" : "violet"}
                  onClick={() => act("view", {
                    id: ticket.id,
                  })}>
                  <u>
                    {"#" + ticket.id}/{ticket.tier == "admin" ? "A" : "M"}
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
                    {ticket.initiator_key_name}
                    {ticket.disconnected ? " \\ [DC]" : ""}
                  </u>
                </Button>
              </Table.Cell>
              {actions.map(action => (
                <Table.Cell key={action[0]} collapsing>
                  <Button
                    content={capitalize(action[0])}
                    onClick={() => act(action[0], {
                      id: ticket.id,
                    })}
                    color={action[1]} />
                </Table.Cell>
              ))}

              {show_xfer ?

                <Fragment><Fragment>{
                  ticket.tier == "mentor"?
                  //Class-Dependent
                    <Table.Cell key={"ahelp"} collapsing>
                      <Button
                        content={"Ahelp"}
                        onClick={() => act("ahelp", {
                          id: ticket.id,
                        })}
                        color={"bad"} />
                    </Table.Cell>
                  :
                    <Table.Cell key={"mhelp"} collapsing>
                    <Button
                      content={"Mhelp"}
                      onClick={() => act("mhelp", {
                        id: ticket.id,
                      })}
                      color={"violet"} />
                    </Table.Cell>
                }</Fragment>

              <Table.Cell
              key={"transfer"}
              collapsing>
              <Button
                content={"Transfer"}
                onClick={() => act("transfer", {
                  id: ticket.id,
                })}
                color={"label"} />
              </Table.Cell></Fragment>

              :null}
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
