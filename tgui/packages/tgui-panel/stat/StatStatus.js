import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatText } from './StatText'

export const StatStatus = (props, context) => {
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
    <Flex direction="column">
      <Flex.Item mt={1}>
        <Flex direction="column">
          <div className="StatBorder_observer">
            <Flex.Item>
              <Section
                className='deadsay'>
                You are <b>dead</b>!
              </Section>
            </Flex.Item>
            <Flex.Item>
              <Section
                className='deadsay'>
                Don't worry, you can still get back into the game if your body is revived or through ghost roles.
              </Section>
            </Flex.Item>
          </div>
        </Flex>
      </Flex.Item>
      <Flex.Item mt={1}>
        <Flex direction="column">
          <div className="StatBorder_antagonist">
            <Flex.Item>
              <Section
                className='stat_antagonist'>
                You are the <b>Traitor</b>!
              </Section>
            </Flex.Item>
            <Flex.Item>
              <Section
                className='stat_antagonist'>
                Complete your
                <Button
                  content="objectives,"
                  color="transparent"
                  className='stat_antagonist_underline'/>
                no matter the cost.
              </Section>
            </Flex.Item>
          </div>
        </Flex>
      </Flex.Item>
      <StatText />
    </Flex>
  );
};
