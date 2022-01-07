import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Tabs, ProgressBar, Section, Flex, Icon, NoticeBox } from '../components';
import { Window } from '../layouts';

export const AiResources = (props, context) => {
  const { act, data } = useBackend(context);

  const { username, has_access } = data;

  const [tab, setTab] = useLocalState(context, 'tab', 1);

  return (
    <Window
      width={500}
      height={450}
      resizable>
      <Window.Content scrollable>
        {!!data.authenticated && (
          <Fragment>
            <Tabs>
              <Tabs.Tab
                selected={tab === 1}
                onClick={(() => setTab(1))}>
                Resource Allocation
              </Tabs.Tab>
              <Tabs.Tab
                selected={tab === 2}
                onClick={(() => setTab(2))}>
                Settings
              </Tabs.Tab>
            </Tabs>
            {tab === 1 && (
              <Fragment>
                <Section title="Cloud CPU Resources" buttons={(
                  <Button icon="sign-out-alt" color="bad" onClick={() => act("log_out")}>Log Out</Button>
                )}>
                  <ProgressBar
                    value={data.total_assigned_cpu}
                    ranges={{
                      good: [data.total_cpu * 0.8, Infinity],
                      average: [data.total_cpu * 0.4, data.total_cpu * 0.8],
                      bad: [-Infinity, data.total_cpu * 0.4],
                    }}
                    maxValue={data.total_cpu}>{data.total_assigned_cpu}/{data.total_cpu} THz
                  </ProgressBar>
                </Section>
                <Section title="Cloud RAM Resources">
                  <ProgressBar
                    ranges={{
                      good: [data.total_ram * 0.8, Infinity],
                      average: [data.total_ram * 0.4, data.total_ram * 0.8],
                      bad: [-Infinity, data.total_ram * 0.4],
                    }}
                    value={data.total_assigned_ram}
                    maxValue={data.total_ram}>{data.total_assigned_ram}/{data.total_ram} TB
                  </ProgressBar>
                </Section>
                <Section title="Active AI's">
                  <LabeledList>


                    {data.ais.map((ai, index) => {
                      return (
                        <Section key={index} title={ai.name}
                          buttons={(
                            <Button icon="trash" onClick={() => act("clear_ai_resources", { targetAI: ai.ref })}>Clear AI Resources</Button>
                          )}>
                          <LabeledList.Item>
                            CPU Capacity:
                            <Flex>
                              <ProgressBar minValue={0} value={ai.assigned_cpu}
                                maxValue={data.total_cpu} >{ai.assigned_cpu} THz
                              </ProgressBar>
                              <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_cpu", {
                                targetAI: ai.ref,
                              })} />
                              <Button height={1.75} icon="minus" onClick={() => act("remove_cpu", {
                                targetAI: ai.ref,
                              })} />
                            </Flex>

                          </LabeledList.Item>
                          <LabeledList.Item>
                            RAM Capacity:
                            <Flex>
                              <ProgressBar minValue={0} value={ai.assigned_ram}
                                maxValue={data.total_ram} >{ai.assigned_ram} TB
                              </ProgressBar>
                              <Button mr={1} ml={1} height={1.75} icon="plus" onClick={() => act("add_ram", {
                                targetAI: ai.ref,
                              })} />
                              <Button height={1.75} icon="minus" onClick={() => act("remove_ram", {
                                targetAI: ai.ref,
                              })} />
                            </Flex>

                          </LabeledList.Item>
                        </Section>
                      );
                    })}
                  </LabeledList>
                </Section>
              </Fragment>
            )}
            {tab === 2 && (
              <Section title="Settings">
                <Button icon="male" color={data.human_only ? "bad" : "good"} onClick={() => act("toggle_human_status")}>{data.human_only ? "Allow Silicon Console Usage" : "Ban Silicon Console Usage"}</Button>
              </Section>
            )}

          </Fragment>
        ) || (
          <Section title="Welcome">
            <Flex align="center" justify="center" mt="0.5rem">
              <Flex.Item>
                <Fragment>
                  {data.user_image && (
                    <Fragment style={`position:relative`}>
                      <img src={data.user_image}
                        width="125px" height="125px"
                        style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;
                        margin-right:-125px`} />
                      <img src="scanlines.png"
                        width="125px" height="125px"
                        style={`-ms-interpolation-mode: nearest-neighbor;
                        border-radius: 50%; border: 3px solid white;opacity: 0.3;`} />
                    </Fragment>
                  ) || (
                    <Icon name="user-circle"
                      verticalAlign="middle" size="4.5" mr="1rem" />
                  )}
                  <Box inline fontSize="18px" bold>{username ? username : "Unknown"}</Box>
                  <NoticeBox success={has_access} danger={!has_access}
                    textAlign="center" mt="1.5rem">
                    {has_access ? "Access Granted" : "Access Denied"}
                  </NoticeBox>
                  <Box textAlign="center">
                    <Button icon="sign-in-alt" color={has_access ? "good" : "bad"} fluid
                      onClick={() => {
                        act("log_in");
                      }} >
                      Log In
                    </Button>
                  </Box>
                </Fragment>
              </Flex.Item>
            </Flex>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
