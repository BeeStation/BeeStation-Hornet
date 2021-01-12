import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Section } from 'tgui/components';
import { Box } from '../../tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus } from './StatStatus';
import { StatText } from './StatText';

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
    <Flex
      height="100%"
      direction="column">
      <Flex.Item>
        {settings.statTabMode === "Scroll"
          ? <StatTabScroll />
          : <StatTabWrap />}
      </Flex.Item>
      <Flex.Item
        overflowY="scroll"
        grow={1}
        mt={1}>
        {statSection}
      </Flex.Item>
    </Flex>
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
