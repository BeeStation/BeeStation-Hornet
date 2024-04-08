import { useSelector } from 'common/redux';
import { decodeHtmlEntities } from 'common/string';
import { Box, Section } from 'tgui/components';
import { selectStatPanel } from './selectors';
import { Table } from '../../tgui/components';

export const StatTicket = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData) {
    return <Box color="red">Passed stat panel data was null, contact coderperson.</Box>;
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
  if (!statPanelData.messages) {
    return <Box>No data.</Box>;
  }
  let invertedArray = statPanelData.messages.slice(0).reverse();
  return (
    <Box>
      <Table>
        {invertedArray.map((message) => (
          <Section key={message.time}>
            <Table.Row>
              <Table.Cell>{message.time}</Table.Cell>
              <Table.Cell color={message.color}>
                <Box>
                  <Box inline bold>
                    {message.from && message.to
                      ? 'PM from ' + decodeHtmlEntities(message.from) + ' to ' + decodeHtmlEntities(message.to)
                      : decodeHtmlEntities(message.from)
                        ? 'Reply PM from ' + decodeHtmlEntities(message.from)
                        : decodeHtmlEntities(message.to)
                          ? 'PM to ' + decodeHtmlEntities(message.to)
                          : ''}
                  </Box>
                  <Box inline>: {decodeHtmlEntities(message.message)}</Box>
                </Box>
              </Table.Cell>
            </Table.Row>
          </Section>
        ))}
      </Table>
    </Box>
  );
};
