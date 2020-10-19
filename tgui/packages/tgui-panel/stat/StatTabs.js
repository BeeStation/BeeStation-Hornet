import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus } from './StatStatus';
import { StatText } from './StatText';

export const StatTabs = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
  let statSection = (<StatText />);
  switch(stat.selectedTab)
  {
    case 'Status':
      statSection = (<StatStatus />);
      break;
  }
  //Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Flex
      direction="column">
      <Flex.Item>
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
      </Flex.Item>
      <Flex.Item
        grow={1}
        mt={1}>
        {statSection}
      </Flex.Item>
    </Flex>
  );
};
