import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber, Dimmer, NoticeBox, Stack, Flex, Icon } from '../components';
import { Window } from '../layouts';
import { clamp01, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';

export const WallHypospray = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    chems = [],
    selected_chem,
    locked,
    handle,
    bottle,
    bottle_volume,
    bottle_max_volume,
    chem_source,
    charge,
    max_charge,
  } = data;

  return (
    <Window
      width={350}
      height={280}>
      {
        !!locked && (
          <Dimmer>
            <NoticeBox>
              <Stack vertical align="center">
                <Stack.Item>
                  Interface locked
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color="red" icon="unlock"
                    content="Unlock"
                    onClick={() => act("toggle_locked")}
                  />
                </Stack.Item>
              </Stack>
            </NoticeBox>
          </Dimmer>
        )
      }
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Stack align="baseline" mx={0.5}>
              <Stack.Item>
                Charge:
              </Stack.Item>
              <Stack.Item grow>
                <ProgressBar
                  minValue={0}
                  maxValue={max_charge}
                  value={charge}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <LabeledList>
                <LabeledList.Item
                  label="Handle holder"
                  buttons={
                    <Button
                      content={handle ?? "Empty"}
                      icon="eject" fluid
                      textAlign="left"
                      onClick={() => act("interact_handle")} />
                  }
                />
                <LabeledList.Item
                  label="Bottle holder"
                  buttons={
                    <ProgressBarButton
                      content={bottle ?? "Empty"}
                      icon="eject" fluid
                      textAlign="left"
                      onClick={() => act("interact_storage")}
                      value={bottle
                        ? (bottle_volume/bottle_max_volume)
                        : 1}
                      progressbar_color="green" />
                  }
                />
                <LabeledList.Item
                  label="Spraying source"
                  buttons={
                    <>
                      <Button
                        color={chem_source === "synthesizer" && "green"}
                        onClick={() => act("select_source", { target: "synthesizer" })}
                        content="Synthesizer" textAlign="left" />
                      <Button 
                        color={chem_source === "bottle" && "green"}
                        onClick={() => act("select_source", { target: "bottle" })}
                        content="Bottle" textAlign="left" />
                    </>
                  }
                />
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section
              title="Internal synthesizer">
              <Flex wrap="wrap">
                {
                  chems.map(chem => (
                    <Flex.Item key={chem.id}>
                      <Button
                        color={chem.name===selected_chem && "green"}
                        content={chem.name}
                        onClick={() => act("select_chem", { "target": chem.id })}
                        m={0.1}
                      />
                    </Flex.Item>
                  ))
                }
              </Flex>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ProgressBarButton = (props, context) => {
  const {
    value,
    progressbar_color,
    content,
    icon,
    iconRotation,
    iconSpin,
    ...rest
  } = props;

  return (
    <Button
      position="relative"
      overflow="hidden"
      {...rest}>
      <Box
        className="ProgressBar__fill ProgressBar__fill--animated"
        backgroundColor="green"
        style={{
          width: clamp01(value) * 100 + '%',
        }} />
      <Box className="ProgressBar__content" inline>
        {icon && (
          <Icon
            name={icon}
            rotation={iconRotation}
            spin={iconSpin} />
        )}
        {content}
      </Box>
    </Button>
  );
};