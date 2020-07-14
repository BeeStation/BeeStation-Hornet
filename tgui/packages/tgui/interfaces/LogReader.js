import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Collapsible, BlockQuote } from '../components';
import { Window } from '../layouts';
import { capitalize, createSearch } from 'common/string';
import { Fragment } from 'inferno';

export const LogReader = (props, context) => {
  return (
    <Window
      theme="admin"
      resizable>
      <Window.Content scrollable>
        <LogsSearch />
        <Logs />
      </Window.Content>
    </Window>
  );
};

export const LogsSearch = (props, context) => {
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  return (
    <Section>
      Filter:
      <Input
        value={searchText}
        onInput={(e, value) => setSearchText(value)}
        mx={1} />
    </Section>
  );
};

export const Logs = (props, context) => {
  const { data } = useBackend(context);
  const {
    logs = [],
  } = data;
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const testSearch = createSearch(searchText, item => {
    return item;
  });
  const items = searchText.length > 0
    && logs
      .filter(testSearch)
    || logs;
  let i = 0;
  return (
    <Section>
      {items.map(log => (
        <Box
          key={log}
          backgroundColor={i++%2===0?"default":"#39363F"}>
          {log}
        </Box>
      ))}
    </Section>
  );
};
