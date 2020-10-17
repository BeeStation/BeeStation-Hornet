import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';

export const StatText = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  let statPanelData = [];
  if(stat.infomationUpdate) {
    for (const [key, value] of Object.entries(stat.infomationUpdate)) {
      if(key === stat.selectedTab) {
        statPanelData = value;
      }
    }
  }
  return (
    <Flex.Item mt={1}>
      <Flex direction="column">
        <div className="StatBorder">
          <Section>
            {statPanelData
              ? Object.keys(statPanelData).map(key => (
                <Flex.Item mt={1}>
                  {key}:
                  <b>
                    {statPanelData[key]}
                  </b>
                </Flex.Item>
              ))
              : "No data"}
          </Section>
        </div>
      </Flex>
    </Flex.Item>
  );
};
