import { useDispatch, useSelector } from 'common/redux';
import { Button, Flex, Box, Section } from 'tgui/components';
import { selectStatPanel } from './selectors';
import { StatText } from './StatText';
import { sendMessage } from 'tgui/backend';


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
          <Flex.Item mt={1} mb={1}>
            <Flex direction="column">
              <div className="StatBorder_observer">
                <Flex.Item>
                  <Box
                    className="deadsay">
                    <Button
                      color="transparent"
                      icon="times"
                      onClick={() => dispatch({
                        type: 'stat/clearDeadPopup',
                      })} />
                    You are <b>dead</b>!
                  </Box>
                </Flex.Item>
                <Flex.Item mt={2}>
                  <Box
                    className="deadsay">
                    Don&#39;t worry, you can still get back into the game
                    if your body is revived or through ghost roles.
                  </Box>
                </Flex.Item>
              </div>
            </Flex>
          </Flex.Item>
        )
        :null}
      {stat.alert_popup
        ?(
          <Flex.Item mt={1} mb={1}>
            <div className="StatBorder_infomation">
              <Box>
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
              </Box>
            </div>
          </Flex.Item>
        )
        :null}
      {stat.antagonist_popup
        ?(
          <Flex.Item mt={1} mb={1}>
            <div className="StatBorder_antagonist">
              <Box>
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
              </Box>
            </div>
          </Flex.Item>
        )
        :null}
      {stat.alert_br
        ?(
          <Flex.Item mt={1} mb={1}>
            <div className="StatBorder_br">
              <Box>
                <Flex
                  direction="column"
                  className="stat_br">
                  <Flex.Item bold>
                    <Button
                      color="transparent"
                      icon="times"
                      onClick={() => dispatch({
                        type: 'stat/clearAlertBr',
                      })} />
                    <Box inline>
                      {stat.alert_br.title}
                    </Box>
                  </Flex.Item>
                  <Flex.Item mt={2}>
                    {stat.alert_br.text}
                  </Flex.Item>
                  <Flex.Item>
                    <Button
                      content="Start"
                      color="transparent"
                      onClick={e => sendMessage({
                        type: 'stat/pressed',
                        payload: {
                          action_id: 'start_br',
                        },
                      })} />
                    <Box inline>
                      <Button
                        content="Dismiss"
                        color="transparent"
                        onClick={() => dispatch({
                          type: 'stat/clearAlertBr',
                        })} />
                    </Box>
                  </Flex.Item>
                </Flex>
              </Box>
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
      {stat.alert_br
        ?(
          <div className="StatBorder_br">
            <Section>
              <Box className="stat_br">
                <Button
                  color="transparent"
                  icon="times"
                  onClick={() => dispatch({
                    type: 'stat/clearAlertBr',
                  })} />
                <Box inline>
                  {stat.alert_br.title}
                </Box>
                <Box>
                  {stat.alert_br.text}
                </Box>
                <Box>
                  <Button
                    content="Start"
                    color="transparent"
                    onClick={e => sendMessage({
                      type: 'stat/pressed',
                      payload: {
                        action_id: 'start_br',
                      },
                    })} />
                  <Box inline>
                    <Button
                      content="Dismiss"
                      color="transparent"
                      onClick={() => dispatch({
                        type: 'stat/clearAlertBr',
                      })} />
                  </Box>
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
