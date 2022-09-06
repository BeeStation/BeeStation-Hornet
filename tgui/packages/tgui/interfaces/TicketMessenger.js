import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Input, Section, Table, Divider } from '../components';
import { Window } from '../layouts';
import { round } from 'common/math';
import { ButtonConfirm } from '../components/Button';

export const TicketMessenger = (props, context) => {
  return (
    <Window
      theme="admin"
      width={620}
      height={500}>
      <Window.Content>
        <Section
          height="85px">
          <TicketActionBar />
        </Section>
        <Section>
          <TicketChatWindow />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketActionBar = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    disconnected,
    time_opened,
    world_time,
    claimee_key,
    antag_status,
    id,
    sender,
    is_admin_type,
  } = data;
  return (
    <Box>
      <Box
        bold
        inline>
        {is_admin_type ? "Admin" : "Mentor"} Help Ticket #{id} : {sender}
      </Box>
      {antag_status ? (
        <Box inline color={antag_status === 'None' ? 'green' : 'red'}>
          Antag: {antag_status}
        </Box>
      ) : null}
      <Box />
      <Box
        inline
        color={claimee_key?"blue":"red"}
        bold>
        Claimed by {claimee_key ? claimee_key : "Nobody"}
      </Box>
      <Box
        inline>
        |
      </Box>
      <Box
        inline
        bold>
        Opened {round((world_time - time_opened)/600)} minutes ago
      </Box>
      <Box
        inline>
        {" |"}
        <Button
          color="transparent"
          content="Re-title"
          onClick={() => act("retitle")} />
        |
        <Button
          color="transparent"
          content="Reopen"
          onClick={() => act("reopen")} />
        |
      </Box>
      <Divider />
      <Box>
        {is_admin_type ? (disconnected
          ? "DISCONNECTED"
          : <TicketFullMonty />) : null}
        <TicketClosureStates admin={is_admin_type} />
      </Box>
    </Box>
  );
};

export const TicketFullMonty = (_, context) => {
  const { act } = useBackend(context);
  return (
    <Box inline>
      <Button
        color="purple"
        content="?"
        onClick={() => act("moreinfo")} />
      <Button
        color="blue"
        content="PP"
        onClick={() => act("playerpanel")} />
      <Button
        color="blue"
        content="VV"
        onClick={() => act("viewvars")} />
      <Button
        color="blue"
        content="SM"
        onClick={() => act("subtlemsg")} />
      <Button
        color="blue"
        content="FLW"
        onClick={() => act("flw")} />
      <Button
        color="blue"
        content="TP"
        onClick={() => act("traitorpanel")} />
      <Button
        color="green"
        content="LOG"
        onClick={() => act("viewlogs")} />
      <Button
        color="red"
        content="SMITE"
        onClick={() => act("smite")} />
    </Box>
  );
};

export const TicketClosureStates = ({ admin }, context) => {
  const { act } = useBackend(context);
  return (
    <Box inline>
      <ButtonConfirm
        content="REJT"
        onClick={() => act("reject")} />
      {admin ? (
        <>
          <ButtonConfirm
            content="IC"
            onClick={() => act("markic")} />
          <ButtonConfirm
            content="CLOSE"
            onClick={() => act("close")} />
        </>
      ): null}
      <Button
        content="RSLVE"
        onClick={() => act("resolve")} />
      <ButtonConfirm
        content={admin ? "MHELP" : "AHELP"}
        onClick={() => act(`${admin ? "mentor" : "admin"}help`)} />
    </Box>
  );
};

export const TicketChatWindow = (_, context) => {
  const { act, data } = useBackend(context);
  const {
    messages = [],
  } = data;
  return (
    <Box>
      <Box
        overflowY="scroll"
        height="315px">
        <Table>
          {messages.map(message => (
            <Section independent
              key={message.time}>
              <Table.Row>
                <Table.Cell>
                  {message.time}
                </Table.Cell>
                <Table.Cell
                  color={message.color}>
                  <Box>
                    <Box
                      inline
                      bold>
                      {message.from && message.to
                        ? "PM from " + decodeHtmlEntities(message.from)
                        + " to " + decodeHtmlEntities(message.to)
                        : decodeHtmlEntities(message.from)
                          ? "Reply PM from " + decodeHtmlEntities(message.from)
                          : decodeHtmlEntities(message.to)
                            ? "PM to " + decodeHtmlEntities(message.to)
                            : ""}
                    </Box>
                    <Box
                      inline>
                      {decodeHtmlEntities(message.message)}
                    </Box>
                  </Box>
                </Table.Cell>
              </Table.Row>
            </Section>
          ))}
        </Table>
      </Box>
      <Divider />
      <Input
        fluid
        selfClear
        onEnter={(e, value) => act("sendpm", {
          text: value,
        })} />
    </Box>
  );
};
