import { toFixed } from 'common/math';
import { useDispatch, useSelector } from 'common/redux';
import { Fragment } from 'inferno';
import { Button, Flex, Knob, Tabs, Box, Section } from 'tgui/components';
import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatText } from './StatText'

export const StatStatus = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
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
      {stat.dead_popup
        ?(<Flex.Item mt={1}>
            <Flex direction="column">
              <div className="StatBorder_observer">
                <Flex.Item>
                  <Section
                    className='deadsay'>
                    <Button
                      color="transparent"
                      icon="times"
                      onClick={() => dispatch({
                        type: 'stat/clearDeadPopup',
                      })} />
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
        )
        :null}
      {stat.antagonist_popup
        ?(
          <Flex.Item mt={1}>
            <div className="StatBorder_antagonist">
              <Section>
                <Flex
                  direction="column"
                  className='stat_antagonist'>
                  <Flex.Item bold>
                    <Button
                      color="transparent"
                      icon="times"
                      onClick={() => dispatch({
                        type: 'stat/clearAntagPopup',
                      })} />
                    <Box inline>
                      {stat.antagonist_popup.title}
                    </Box>
                  </Flex.Item>
                  <Flex.Item mt={2}>
                    {stat.antagonist_popup.text}
                  </Flex.Item>
                </Flex>
              </Section>
            </div>
          </Flex.Item>
        )
        :null}
      <StatText />
    </Flex>
  );
};
