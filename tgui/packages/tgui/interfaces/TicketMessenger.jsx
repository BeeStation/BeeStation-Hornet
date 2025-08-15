import { round } from 'common/math';
import { decodeHtmlEntities } from 'common/string';
import { Component, createRef } from 'react';

import { useBackend } from '../backend';
import { Box, Button, Divider, Input, Section, Table } from '../components';
import { ButtonConfirm } from '../components/Button';
import { Window } from '../layouts';

export const TicketMessenger = (props) => {
  return (
    <Window theme="admin" width={620} height={500}>
      <Window.Content>
        <Section height="85px">
          <TicketActionBar />
        </Section>
        <Section>
          <TicketChatWindow />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketActionBar = (props) => {
  const { act, data } = useBackend();
  const {
    disconnected,
    time_opened,
    world_time,
    claimee_key,
    antag_status,
    id,
    sender,
    is_admin_type,
    open,
  } = data;
  return (
    <Box>
      <Box bold inline>
        {is_admin_type ? 'Admin' : 'Mentor'} Help Ticket #{id} by {sender}
      </Box>
      {antag_status ? (
        <>
          &nbsp;|&nbsp;
          <Box inline color={antag_status === 'None' ? 'green' : 'red'}>
            Antag: {antag_status}
          </Box>
        </>
      ) : null}
      <Box />
      <Box inline color={claimee_key ? 'blue' : 'red'} bold>
        Claimed by {claimee_key ? claimee_key : 'Nobody'}
      </Box>
      <Box inline>&nbsp;|&nbsp;</Box>
      <Box inline bold>
        Opened {round((world_time - time_opened) / 600)} minutes ago
      </Box>
      <Box inline>
        &nbsp;|&nbsp;
        <Button content="Re-title" onClick={() => act('retitle')} />
        {!open ? (
          <>
            &nbsp;|&nbsp;
            <Button content="Reopen" onClick={() => act('reopen')} />
          </>
        ) : null}
      </Box>

      <Divider />
      <Box>
        {is_admin_type ? (
          disconnected ? (
            'DISCONNECTED'
          ) : (
            <TicketFullMonty />
          )
        ) : null}
        <TicketClosureStates admin={is_admin_type} />
      </Box>
    </Box>
  );
};

export const TicketFullMonty = (_) => {
  const { act } = useBackend();
  return (
    <Box inline>
      <Button color="purple" content="?" onClick={() => act('moreinfo')} />
      <Button color="blue" content="PP" onClick={() => act('playerpanel')} />
      <Button color="blue" content="VV" onClick={() => act('viewvars')} />
      <Button color="blue" content="SM" onClick={() => act('subtlemsg')} />
      <Button color="blue" content="FLW" onClick={() => act('flw')} />
      <Button color="blue" content="TP" onClick={() => act('traitorpanel')} />
      <Button color="green" content="LOG" onClick={() => act('viewlogs')} />
      <Button color="red" content="SMITE" onClick={() => act('smite')} />
    </Box>
  );
};

export const TicketClosureStates = ({ admin }) => {
  const { act } = useBackend();
  return (
    <Box inline>
      <ButtonConfirm content="REJT" onClick={() => act('reject')} />
      {admin ? (
        <>
          <ButtonConfirm content="IC" onClick={() => act('markic')} />
          <ButtonConfirm content="CLOSE" onClick={() => act('close')} />
        </>
      ) : null}
      <Button content="RSLVE" onClick={() => act('resolve')} />
      <ButtonConfirm
        content={admin ? 'MHELP' : 'AHELP'}
        onClick={() => act(`${admin ? 'mentor' : 'admin'}help`)}
      />
    </Box>
  );
};

export const TicketChatWindow = (_) => {
  const { act, data } = useBackend();
  const { messages = [] } = data;
  return (
    <Box>
      <Box overflowY="scroll" height="315px">
        <Table>
          <TicketMessages messages={messages} />
        </Table>
      </Box>
      <Divider />
      <Input
        fluid
        selfClear
        onEnter={(e, value) =>
          act('sendpm', {
            text: value,
          })
        }
      />
    </Box>
  );
};

class TicketMessages extends Component {
  constructor(props) {
    super(props);
    this.messagesEndRef = createRef();
  }

  componentDidMount() {
    this.scrollToBottom();
  }

  componentDidUpdate(oldProps) {
    if (oldProps.messages.length !== this.props.messages.length) {
      this.scrollToBottom();
    }
  }

  scrollToBottom = () => {
    this.messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  render() {
    const { messages } = this.props;
    return (
      <>
        {messages.map((message) => (
          <Section independent key={message.time}>
            <Table.Row>
              <Table.Cell>{message.time}</Table.Cell>
              <Table.Cell color={message.color}>
                <Box>
                  <Box bold>
                    {message.from && message.to
                      ? 'PM from ' +
                        decodeHtmlEntities(message.from) +
                        ' to ' +
                        decodeHtmlEntities(message.to)
                      : decodeHtmlEntities(message.from)
                        ? 'Reply PM from ' + decodeHtmlEntities(message.from)
                        : decodeHtmlEntities(message.to)
                          ? 'PM to ' + decodeHtmlEntities(message.to)
                          : ''}
                  </Box>
                  <Box>{decodeHtmlEntities(message.message)}</Box>
                </Box>
              </Table.Cell>
            </Table.Row>
          </Section>
        ))}
        <div ref={this.messagesEndRef} />
      </>
    );
  }
}
