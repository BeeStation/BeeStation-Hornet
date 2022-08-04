import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Collapsible, BlockQuote } from '../components';
import { Window } from '../layouts';
import { capitalize } from 'common/string';
import { ButtonConfirm } from '../components/Button';

export const TicketBrowser = (props, context) => {
  const { data } = useBackend(context);
  const {
    unclaimed_tickets = [],
    open_tickets = [],
    closed_tickets = [],
    resolved_tickets = [],
    unclaimed_tickets_mentor = [],
    open_tickets_mentor = [],
    closed_tickets_mentor = [],
    resolved_tickets_mentor = [],
    admin_ckey,
    is_admin_panel,
  } = data;
  return (
    <Window theme="admin" width={720} height={480}>
      <Window.Content scrollable>
        <h2>{is_admin_panel ? 'Administrator' : 'Mentor'}: {admin_ckey}</h2>
        <TicketMenus
          unclaimed_tickets={unclaimed_tickets}
          open_tickets={open_tickets}
          resolved_tickets={resolved_tickets}
          closed_tickets={closed_tickets}
        />
        {is_admin_panel ? (
          <>
            <h2>Mentor Tickets</h2>
            <TicketMenus
              unclaimed_tickets={unclaimed_tickets_mentor}
              open_tickets={open_tickets_mentor}
              resolved_tickets={resolved_tickets_mentor}
              closed_tickets={closed_tickets_mentor}
              collapsible
            />
          </>
        ) : null}
      </Window.Content>
    </Window>
  );
};

export const CollapsibleSection = ({ collapsible, children, ...remainder }) => (
  <Section {...remainder}>
    {collapsible ? <Collapsible open>{children}</Collapsible> : children}
  </Section>
);

export const TicketMenus = ({
  unclaimed_tickets,
  open_tickets,
  resolved_tickets,
  closed_tickets,
  collapsible,
}) => {
  return (
    <CollapsibleSection collapsible={collapsible}>
      <TicketMenu
        ticket_list={unclaimed_tickets}
        name={'Unclaimed Tickets'}
        actions={[['claim', 'good']]}
        actions_confirm={[['reject', 'bad']]}
        admin_actions={[['flw', 'blue']]}
        admin_actions_confirm={[
          ['mhelp', 'label'],
          ['ic', 'label'],
        ]}
      />
      <TicketMenu
        ticket_list={open_tickets}
        name={'Claimed Tickets'}
        actions={[
          ['claim', 'average'],
          ['resolve', 'good'],
        ]}
        actions_confirm={[
          ['reject', 'bad'],
          ['close', 'label'],
        ]}
        admin_actions={[['flw', 'blue']]}
        admin_actions_confirm={[
          ['mhelp', 'label'],
          ['ic', 'label'],
        ]}
      />
      <TicketMenu
        ticket_list={resolved_tickets}
        name={'Resolved Tickets'}
        actions={[['reopen', 'good']]}
        admin_actions={[['flw', 'blue']]}
        collapsible
      />
      <TicketMenu
        ticket_list={closed_tickets}
        name={'Closed Tickets'}
        actions={[['reopen', 'good']]}
        admin_actions={[['flw', 'blue']]}
        collapsible
      />
    </CollapsibleSection>
  );
};

export const TicketMenu = (props, context) => {
  const {
    ticket_list,
    name,
    actions = [],
    admin_actions = [],
    actions_confirm = [],
    admin_actions_confirm = [],
    collapsible,
  } = props;
  const { act } = useBackend(context);
  return (
    <CollapsibleSection title={name} collapsible={collapsible}>
      <Table>
        {ticket_list.map((ticket) => (
          <Section independent key={ticket.name}>
            <Table.Row>
              <Table.Cell bold collapsing>
                <Button
                  color="transparent"
                  onClick={() =>
                    act('view', {
                      id: ticket.id,
                    })}>
                  <u>
                    {(ticket.is_admin_type ? '' : '[MENTOR] ')
                      + '#'
                      + ticket.id}
                  </u>
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  color={ticket.disconnected ? 'bad' : 'transparent'}
                  onClick={() =>
                    act('pm', {
                      id: ticket.id,
                    })}>
                  <u>
                    {ticket.initiator_key_name} \
                    {ticket.disconnected ? '[DC]' : ''}
                  </u>
                </Button>
              </Table.Cell>
              {actions?.map((action) => (
                <ActionButton
                  key={action[0]}
                  action={action}
                  ticket_id={ticket.id}
                />
              ))}
              {actions_confirm?.map((action) => (
                <ActionButton
                  key={action[0]}
                  action={action}
                  ticket_id={ticket.id}
                  confirm
                />
              ))}
              {admin_actions?.map((action) => (
                <ActionButton
                  key={action[0]}
                  action={action}
                  ticket_id={ticket.id}
                />
              ))}
              {(ticket.is_admin_type
                ? admin_actions_confirm
                : [['ahelp', 'label']]
              ).map((action) => (
                <ActionButton
                  key={action[0]}
                  action={action}
                  ticket_id={ticket.id}
                  confirm
                />
              ))}
            </Table.Row>
            <BlockQuote>{ticket.name}</BlockQuote>
            <Box color={ticket.claimed_key_name ? 'good' : 'bad'}>
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
    </CollapsibleSection>
  );
};

export const ActionButton = ({ action, confirm, ticket_id }, context) => {
  const { act } = useBackend(context);
  return (
    <Table.Cell collapsing>
      {confirm ? (
        <ButtonConfirm
          content={capitalize(action[0])}
          onClick={() =>
            act(action[0], {
              id: ticket_id,
            })}
          color={action[1]}
        />
      ) : (
        <Button
          content={capitalize(action[0])}
          onClick={() =>
            act(action[0], {
              id: ticket_id,
            })}
          color={action[1]}
        />
      )}
    </Table.Cell>
  );
};
