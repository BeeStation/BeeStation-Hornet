import { multiline, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Collapsible, BlockQuote, Slider, Divider } from '../components';
import { Window, Layout } from '../layouts';
import { round } from 'common/math';

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
    time_closed,
    world_time,
    ticket_state,
    claimee,
    claimee_key,
    antag_status,
    id,
    sender,
  } = data;
  return (
    <Box>
      <Box
        bold
        inline>
        Admin Help Ticket #{id} : {sender}
      </Box>
      <Box
        inline
        color={antag_status==="None"?"green":"red"}>
        Antag: {antag_status}
      </Box>
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
        {disconnected
          ? "DISCONNECTED"
          : <TicketFullMonty /> }
        <TicketClosureStates />
      </Box>
    </Box>
  );
};

export const TicketFullMonty = (props, context) => {
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

export const TicketClosureStates = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Box inline>
      <Button
        content="REJT"
        onClick={() => act("reject")} />
      <Button
        content="IC"
        onClick={() => act("markic")} />
      <Button
        content="CLOSE"
        onClick={() => act("close")} />
      <Button
        content="RSLVE"
        onClick={() => act("resolve")} />
      <Button
        content="MHELP"
        onClick={() => act("mentorhelp")} />
    </Box>
  );
};

export const TicketChatWindow = (props, context) => {
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
            <Section
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
