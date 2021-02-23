import { useDispatch, useSelector } from 'common/redux';
import { Button, Flex, Box, Section } from 'tgui/components';
import { selectStatPanel } from './selectors';
import { StatText } from './StatText';

export const StatStatus = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
  let statPanelData = [];
  if (stat.infomationUpdate) {
    for (const [key, value] of Object.entries(stat.infomationUpdate)) {
      if (key === stat.selectedTab) {
        statPanelData = value;
      }
    }
  }
  return (
    <Flex direction="column">
      {stat.dead_popup
        ?(
          <Flex.Item mt={1}>
            <Flex direction="column">
              <div className="StatBorder_observer">
                <Flex.Item>
                  <Section
                    className="deadsay">
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
                    className="deadsay">
                    Don&#39;t worry, you can still get back into the game
                    if your body is revived or through ghost roles.
                  </Section>
                </Flex.Item>
              </div>
            </Flex>
          </Flex.Item>
        )
        :null}
      {stat.alert_popup
        ?(
          <Flex.Item mt={1}>
            <div className="StatBorder_infomation">
              <Section>
                <Flex
                  direction="column"
                  className="stat_infomation">
                  <Flex.Item bold>
                    <Button
                      color="transparent"
                      icon="times"
                      onClick={() => dispatch({
                        type: 'stat/clearAlertPopup',
                      })} />
                    <Box inline>
                      {stat.alert_popup.title}
                    </Box>
                  </Flex.Item>
                  <Flex.Item mt={2}>
                    {stat.alert_popup.text}
                  </Flex.Item>
                </Flex>
              </Section>
            </div>
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
                  className="stat_antagonist">
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

// =======================
// Non-Flex Support
// =======================

export const HoboStatStatus = (props, context) => {
  const stat = useSelector(context, selectStatPanel);
  const dispatch = useDispatch(context);
  let statPanelData = [];
  if (stat.infomationUpdate) {
    for (const [key, value] of Object.entries(stat.infomationUpdate)) {
      if (key === stat.selectedTab) {
        statPanelData = value;
      }
    }
  }
  return (
    <Box>
      {stat.dead_popup
        ?(
          <div className="StatBorder_observer">
            <Box>
              <Section
                className="deadsay">
                <Button
                  color="transparent"
                  icon="times"
                  onClick={() => dispatch({
                    type: 'stat/clearDeadPopup',
                  })} />
                You are <b>dead</b>!
              </Section>
            </Box>
            <Box>
              <Section
                className="deadsay">
                Don&#39;t worry, you can still get back into the game
                if your body is revived or through ghost roles.
              </Section>
            </Box>
          </div>
        )
        :null}
      {stat.alert_popup
        ?(
          <div className="StatBorder_infomation">
            <Section>
              <Box className="stat_infomation">
                <Button
                  color="transparent"
                  icon="times"
                  onClick={() => dispatch({
                    type: 'stat/clearAlertPopup',
                  })} />
                <Box inline>
                  {stat.alert_popup.title}
                </Box>
                <Box>
                  {stat.alert_popup.text}
                </Box>
              </Box>
            </Section>
          </div>
        )
        :null}
      {stat.antagonist_popup
        ?(
          <div className="StatBorder_antagonist">
            <Section>
              <Box className="stat_antagonist">
                <Button
                  color="transparent"
                  icon="times"
                  onClick={() => dispatch({
                    type: 'stat/clearAntagPopup',
                  })} />
                <Box inline bold>
                  {stat.antagonist_popup.title}
                </Box>
                <Box>
                  {stat.antagonist_popup.text}
                </Box>
              </Box>
            </Section>
          </div>
        )
        :null}
      <StatText />
    </Box>
  );
};
