import { useDispatch, useSelector } from 'tgui/backend';
import {
  Button,
  Divider,
  Flex,
  Input,
  ScrollableBox,
  Section,
  Tabs,
} from 'tgui/components';

import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus } from './StatStatus';
import { StatText } from './StatText';
import { StatTicket } from './StatTicket';

// =======================
// Flex Supported
// =======================

export const StatTabs = (props) => {
  const stat = useSelector(selectStatPanel);
  const settings = useSettings();
  let statSection = <StatText />;
  switch (stat.selectedTab) {
    case 'Status':
      statSection = <StatStatus />;
      break;
    case '(!) Admin PM':
      statSection = <StatTicket />;
      break;
  }
  return (
    <>
      <Flex.Item shrink={0}>
        <div className="StatTabBackground">
          {settings.statTabMode === 'Scroll' ? (
            <StatTabScroll />
          ) : (
            <StatTabWrap />
          )}
        </div>
      </Flex.Item>
      <ScrollableBox overflowY="scroll" height="100%">
        <div className="StatBackground">
          <Flex.Item mt={1}>{statSection}</Flex.Item>
        </div>
      </ScrollableBox>
      {stat.selectedTab === '(!) Admin PM' && (
        <>
          <Divider />
          <Input
            fluid
            selfClear
            onEnter={(e, value) =>
              Byond.sendMessage('stat/pressed', {
                action_id: 'ticket_message',
                params: {
                  msg: value,
                },
              })
            }
          />
        </>
      )}
    </>
  );
};

export const StatTabScroll = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section fitted overflowX="auto">
      <Flex align="center">
        <Flex.Item>
          <Tabs textAlign="center">
            {statTabs.map((tab) => (
              <Tabs.Tab
                key={tab}
                selected={tab === stat.selectedTab}
                onClick={() =>
                  dispatch({
                    type: 'stat/setTab',
                    payload: tab,
                  })
                }
              >
                {tab}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const StatTabWrap = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section overflowX="auto">
      {statTabs.map((tab) => (
        <Button
          key={tab}
          color="transparent"
          pr={1.5}
          pl={1.5}
          selected={tab === stat.selectedTab}
          onClick={() =>
            dispatch({
              type: 'stat/setTab',
              payload: tab,
            })
          }
        >
          {tab}
        </Button>
      ))}
    </Section>
  );
};
