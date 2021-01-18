import { useDispatch, useSelector } from 'common/redux';
import { Button, Flex, Knob, Tabs, Section } from 'tgui/components';
import { Box, ScrollableBox, Fragment } from '../../tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus, HoboStatStatus } from './StatStatus';
import { StatText, HoboStatText } from './StatText';

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
  }
  return (
    <Fragment>
      <Flex.Item shrink={0}>
        {settings.statTabMode === "Scroll"
          ? <StatTabScroll />
          : <StatTabWrap />}
      </Flex.Item>
      <ScrollableBox overflowY="scroll">
        <Flex.Item>
          {statSection}
        </Flex.Item>
      </ScrollableBox>
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
  }
  return (
    <Box>
      <StatTabWrap />
      <Box
        grow={1}>
        {statSection}
      </Box>
    </Box>
  );
};
