import { createSearch, decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Divider } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { TableRow } from '../components/Table';

export const ClockworkSlab = (props, context) => {
  const { data } = useBackend(context);
  const { power } = data;
  const { recollection } = data;
  return (
    <Window
      theme="clockwork"
      resizable>
      <Window.Content scrollable>
        <Section
          title={(
            <Box
              inline
              color={'good'}>
              {"Clockwork Slab"}
            </Box>
          )}>
          <ClockworkColorDescription />
          <ClockworkColorDescription />
        </Section>
        <ClockworkInteractableArea />
      </Window.Content>
    </Window>
  );
};

// Descriptive stuff

export const ClockworkColorDescription = (props, context) => {
  const { data } = useBackend(context);
  return (
    <Section>
      <Table>
        <Table.Row>
          <Table.Cell bold>
            {"Colour descriptions go here."}
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

// Actual UI buttons and stuff
export const ClockworkInteractableArea = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    scriptures = [],
    drivers = [],
    applications = [],
  } = data;
  const [
    selectedTab,
  ] = useLocalState(context, 'selectedTab', {});
  return (
    <Section>
      <ClockworkTabButtons />
      <Divider />
      {(selectedTab === "Class Selection")
        ?<ClockworkClassSelection
          selectedTab={selectedTab} />
        : (selectedTab === "Scriptures")
          ? <ClockworkScriptureMenu
            scriptures={scriptures} />
          : (selectedTab === "Drivers")
            ? <ClockworkScriptureMenu
              scriptures={drivers} />
            : <ClockworkScriptureMenu
              scriptures={applications} />}
    </Section>
  );
};

export const ClockworkTabButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', {});
  const tabs = ["Scriptures", "Drivers", "Applications", "Class Selection"];
  return (
    <Table>
      <Table.Row>
        {tabs.map(tab => (
          <Table.Cell
            key={tab}
            collapsing>
            <Button
              key={tab}
              fluid
              content={tab}
              onClick={() => setSelectedTab(tab)} />
          </Table.Cell>
        ))}
      </Table.Row>
    </Table>
  );
};

export const ClockworkScriptureMenu = (props, context) => {
  const { scriptures } = props;
  return (
    <Table>
      {scriptures.map(script => (
        <TableRow
          key={script}>
          <Table.Cell bold>
            {script.name}
          </Table.Cell>
          <Table.Cell>
            {script.desc}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            <Button
              fluid
              content={"Invoke " + script.cost + "W"}
              disabled={false}
              tooltip={script.tip}
              tooltipPosition="left"
              onClick={() => act("invoke", {
                scriptureName: script.name,
              })}>
            </Button>
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            <Button
              fluid
              content={"Quickbind"}
              disabled={false}
              tooltip={script.tip}
              tooltipPosition="left"
              onClick={() => act("invoke", {
                scriptureName: script.name,
              })}>
            </Button>
          </Table.Cell>
        </TableRow>
      ))}
    </Table>
  );
};

export const ClockworkClassSelection = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    servant_classes = [],
  } = data;
  const [
    hoveredItem,
    setHoveredItem,
  ] = useLocalState(context, 'hoveredItem', {});
  return (
    <Table>
      {servant_classes.map(servant_class => (
        <Table.Row
          key={servant_class.classname}
          className="candystripe">
          <Table.Cell bold>
            {decodeHtmlEntities(servant_class.classname)}
          </Table.Cell>
          <Table.Cell collapsing textAlign="right">
            <Button
              fluid
              content={"Invoke"}
              disabled={false}
              tooltip={servant_class.classdesc}
              tooltipPosition="left"
              onmouseover={() => setHoveredItem(servant_class)}
              onmouseout={() => setHoveredItem({})}
              onClick={() => act('setClass', {
                class: servant_class.classname,
              })} />
          </Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
