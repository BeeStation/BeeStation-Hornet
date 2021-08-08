import { useDispatch, useSelector } from 'common/redux';
import { Button, Flex, Tabs, Section, Input } from 'tgui/components';
import { Box, ScrollableBox, Fragment, Divider } from '../../tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus, HoboStatStatus } from './StatStatus';
import { StatText, HoboStatText } from './StatText';
import { StatTicket } from './StatTicket';
import { sendMessage } from 'tgui/backend';

// =======================
// Flex Supported
// =======================

export const StatTabs = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const settings = useSettings(context);
  let statSection = (<StatText />);
  switch (stat.selectedTab) {
    case 'Status':
      statSection = (<StatStatus />);
      break;
    case '(!) Admin PM':
      statSection = (<StatTicket />);
      break;
  }
  return (
    <Fragment>
      <Flex.Item shrink={0}>
        <div className="StatTabBackground">
          {settings.statTabMode === "Scroll"
            ? <StatTabScroll />
            : <StatTabWrap />}
        </div>
      </Flex.Item>
      <ScrollableBox overflowY="scroll" height="100%">
        <div className="StatBackground">
          <Flex.Item mt={1}>
            {statSection}
          </Flex.Item>
        </div>
      </ScrollableBox>
      {stat.selectedTab === '(!) Admin PM' && (
        <Fragment>
          <Divider />
          <Input
            fluid
            selfClear
            onEnter={(e, value) => sendMessage({
              type: 'stat/pressed',
              payload: {
                action_id: "ticket_message",
                params: {
                  msg: value,
                },
              },
            })} />
        </Fragment>
      )}
    </Fragment>
  );
};

export const StatTabScroll = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section
      fitted
      overflowX="auto">
      <Flex align="center">
        <Flex.Item>
          <Tabs textAlign="center">
            {statTabs.map(tab => (
              <Tabs.Tab
                key={tab}
                selected={tab === stat.selectedTab}
                onClick={() => dispatch({
                  type: 'stat/setTab',
                  payload: tab,
                })}>
                {tab}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const StatTabWrap = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section
      overflowX="auto">
      {statTabs.map(tab => (
        <Button
          key={tab}
          color="transparent"
          pr={1.5}
          pl={1.5}
          selected={tab === stat.selectedTab}
          onClick={() => dispatch({
            type: 'stat/setTab',
            payload: tab,
          })}>
          {tab}
        </Button>
      ))}
    </Section>
  );
};

// =======================
// Non-Flex Support
// =======================

export const HoboStatTabs = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const settings = useSettings(context);
  let statSection = (<HoboStatText />);
  switch (stat.selectedTab) {
    case 'Status':
      statSection = (<HoboStatStatus />);
      break;
    case '(!) Admin PM':
      statSection = (<StatTicket />);
      break;
  }
  return (
    <Box>
      <StatTabWrap />
      <Box
        grow={1}>
        {statSection}
      </Box>
      {stat.selectedTab === '(!) Admin PM' && (
        <Fragment>
          <Divider />
          <Input
            fluid
            selfClear
            onEnter={(e, value) => sendMessage({
              type: 'stat/pressed',
              payload: {
                action_id: "ticket_message",
                params: value,
              },
            })} />
        </Fragment>
      )}
    </Box>
  );
};
