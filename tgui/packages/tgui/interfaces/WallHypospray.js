import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section, AnimatedNumber, Dimmer, NoticeBox, Stack, Flex, Icon } from '../components';
import { Window } from '../layouts';
import { clamp01, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';

export const WallHypospray = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    locked,
    handle,
  } = data;

  return (
    <Window
      width={350}
      height={500}>
      {
        !!locked && (
          <Dimmer>
            <NoticeBox>
              <Stack vertical>
                <Stack.Item>
                  Interface locked
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color="red" icon="unlock"
                    content="Unlock" fluid textAlign="center"
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
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <WallHypospraySourceSection
              title="Plumbing system"
              source_name="plumbing">
              <WallHyposprayPlumbing />
            </WallHypospraySourceSection>
          </Stack.Item>
          <Stack.Item>
            <WallHypospraySourceSection
              title="Handle-attached bottle"
              source_name="handle">
              <WallHyposprayHandleBottle />
            </WallHypospraySourceSection>
          </Stack.Item>
          <Stack.Item>
            <WallHypospraySourceSection
              title="Chemistry bag"
              source_name="storage">
              <WallHyposprayChemSelection />
            </WallHypospraySourceSection>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const WallHypospraySourceSection = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    chem_source,
  } = data;

  const {
    source_name,
    children,
    ...rest
  } = props;

  return (
    <Section {...rest}
      buttons={
        <Button
          color={chem_source === source_name && "green"}
          onClick={() => act("select_source", { target: source_name })}
          content="Select"
        />
      }>
      {children}
    </Section>
  );
};

export const WallHyposprayPlumbing = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    plumbing_data,
  } = data;

  return (
    <ProgressBar
      value={plumbing_data.volume/plumbing_data.max_volume}>
      {plumbing_data.volume}u/{plumbing_data.max_volume}u
    </ProgressBar>
  );
};

export const WallHyposprayHandleBottle = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    bottle,
    bottle_data,
  } = data;

  return (
    <ProgressBar
      value={bottle_data && (bottle_data.volume/bottle_data.max_volume)}>
      {bottle ?? "Empty"}
    </ProgressBar>
  );
};

export const WallHyposprayChemSelection = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    bag,
    bag_contents,
    selected,
    selected_data,
  } = data;

  return (
    <>
      <Button 
        content={bag ?? "Empty"}
        icon="eject" fluid
        textAlign="left"
        onClick={() => act("interact_bag")} />
      <ProgressBar
        value={selected_data && (selected_data.volume/selected_data.max_volume)}>
        {
          selected ? (
            selected_data.name + " ["
            + selected_data.volume + "u/"
            + selected_data.max_volume + "u]"
          ) : "Nothing selected"
        }
      </ProgressBar>
      {
        bag ? (
          <Flex wrap="wrap">
            {
              bag_contents.map(item => (
                <Flex.Item key={item.id} mx={0.2}>
                  <ProgressBarButton
                    progressbar_color={item.id===selected && "green"}
                    color={item.id===selected ? "green" : "default"}
                    content={item.name}
                    onClick={() => act("select_storage", { "target": item.id })}
                    value={item.volume/item.max_volume}
                  />
                </Flex.Item>
              ))
            }
          </Flex>
        ) : (
          <NoticeBox>
            No chemistry bag attached
          </NoticeBox>
        )
      }
    </>
  );
};

const ProgressBarButton = (props, context) => {
  const {
    value = 0,
    progressbar_color = "default",
    color = "default",
    content,
    icon,
    iconRotation,
    iconSpin,
    textAlign,
    ...rest
  } = props;

  return (
    <Button
      position="relative"
      overflow="hidden"
      className={classes([
        "HyposprayProgressBarButton",
        "HyposprayProgressBarButton--color--"+color])}
      {...rest}>
      <Box
        className="HyposprayProgressBarButton__fill HyposprayProgressBarButton__fill--animated"
        backgroundColor={progressbar_color}
        style={{
          width: clamp01(value) * 100 + '%',
        }} />
      <Box className="HyposprayProgressBarButton__content" inline textAlign={textAlign}>
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