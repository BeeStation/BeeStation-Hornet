import { capitalize } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Section,
  Table,
  Tabs,
} from '../components';
import { ButtonConfirm } from '../components/Button';
import { Window } from '../layouts';

export const TicketBrowser = (_) => {
  const { data } = useBackend();
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
  const [tab, setTab] = useLocalState('tab', 'admin');
  return (
    <Window theme="admin" width={720} height={540}>
      <Window.Content scrollable>
        <h2>
          {is_admin_panel ? 'Administrator' : 'Mentor'}: {admin_ckey}
        </h2>
        {is_admin_panel ? (
          <Section fill>
            <Tabs>
              <Tabs.Tab
                selected={tab === 'admin'}
                onClick={() => setTab('admin')}
              >
                {`Admin${unclaimed_tickets.length ? ` (${unclaimed_tickets.length})` : ''}`}
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 'mentor'}
                onClick={() => setTab('mentor')}
              >
                {/* eslint-disable-next-line max-len*/}
                {`Mentor${unclaimed_tickets_mentor.length ? ` (${unclaimed_tickets_mentor.length})` : ''}`}
              </Tabs.Tab>
            </Tabs>
            {tab === 'admin' ? (
              <TicketMenus
                unclaimed_tickets={unclaimed_tickets}
                open_tickets={open_tickets}
                resolved_tickets={resolved_tickets}
                closed_tickets={closed_tickets}
              />
            ) : (
              <TicketMenus
                unclaimed_tickets={unclaimed_tickets_mentor}
                open_tickets={open_tickets_mentor}
                resolved_tickets={resolved_tickets_mentor}
                closed_tickets={closed_tickets_mentor}
              />
            )}
          </Section>
        ) : (
          <TicketMenus
            unclaimed_tickets={unclaimed_tickets}
            open_tickets={open_tickets}
            resolved_tickets={resolved_tickets}
            closed_tickets={closed_tickets}
          />
        )}
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
}) => {
  return (
    <>
      <TicketMenu
        ticket_list={unclaimed_tickets}
        name={'Unclaimed Tickets'}
        actions={[['claim', 'good']]}
        actions_confirm={[['reject', 'bad']]}
        admin_actions={[['flw', 'blue']]}
        admin_actions_confirm={[['ic', 'label']]}
        conversion
      />
      <TicketMenu
        ticket_list={open_tickets}
        name={'Claimed Tickets'}
        actions={[
          ['claim', 'average'],
          ['resolve', 'good'],
        ]}
        actions_confirm={[['reject', 'bad']]}
        admin_actions={[
          ['flw', 'blue'],
          ['close', 'label'],
        ]}
        admin_actions_confirm={[['ic', 'label']]}
        conversion
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
    </>
  );
};

export const TicketMenu = (props) => {
  const {
    ticket_list,
    name,
    actions = [],
    admin_actions = [],
    actions_confirm = [],
    admin_actions_confirm = [],
    collapsible,
    conversion,
  } = props;
  const { act } = useBackend();
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
                    })
                  }
                >
                  <u>
                    {(ticket.is_admin_type ? '' : '[MENTOR] ') +
                      '#' +
                      ticket.id}
                  </u>
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  color={ticket.disconnected ? 'bad' : 'transparent'}
                  onClick={() =>
                    act('pm', {
                      id: ticket.id,
                    })
                  }
                >
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
              {ticket.is_admin_type
                ? admin_actions?.map((action) => (
                    <ActionButton
                      key={action[0]}
                      action={action}
                      ticket_id={ticket.id}
                    />
                  ))
                : null}
              {ticket.is_admin_type
                ? admin_actions_confirm?.map((action) => (
                    <ActionButton
                      key={action[0]}
                      action={action}
                      ticket_id={ticket.id}
                      confirm
                    />
                  ))
                : null}
              {conversion ? (
                <ActionButton
                  action={
                    ticket.is_admin_type
                      ? ['mhelp', 'label']
                      : ['ahelp', 'label']
                  }
                  ticket_id={ticket.id}
                  confirm
                />
              ) : null}
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

export const ActionButton = ({ action, confirm, ticket_id }) => {
  const { act } = useBackend();
  return (
    <Table.Cell collapsing>
      {confirm ? (
        <ButtonConfirm
          content={capitalize(action[0])}
          onClick={() =>
            act(action[0], {
              id: ticket_id,
            })
          }
          color={action[1]}
        />
      ) : (
        <Button
          content={capitalize(action[0])}
          onClick={() =>
            act(action[0], {
              id: ticket_id,
            })
          }
          color={action[1]}
        />
      )}
    </Table.Cell>
  );
};
