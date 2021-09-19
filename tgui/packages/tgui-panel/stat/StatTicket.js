import { useSelector } from 'common/redux';
import { decodeHtmlEntities } from 'common/string';
import { Button, Flex, Knob, Tabs, Box, Section, Fragment } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { sendMessage } from 'tgui/backend';
import { Divider, Grid, Table, Input, ScrollableBox } from '../../tgui/components';
import { STAT_TEXT, STAT_BUTTON, STAT_ATOM, STAT_DIVIDER, STAT_VERB } from './constants';

export const StatTicket = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData)
  {
    return (
      <Box color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Box>
    );
  }
  return (
    <Box>
      <Section>
        <StatTicketChat messages={statPanelData.messages} />
      </Section>
    </Box>
  );
};

export const StatTicketChat = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData.messages)
  {
    return (
      <Box>
        No data.
      </Box>
    );
  }
  let invertedArray = statPanelData.messages.slice(0).reverse();
  return (
    <Box>
      <Table>
        {invertedArray.map(message => (
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
                    : {decodeHtmlEntities(message.message)}
                  </Box>
                </Box>
              </Table.Cell>
            </Table.Row>
          </Section>
        ))}
      </Table>
    </Box>
  );
};
