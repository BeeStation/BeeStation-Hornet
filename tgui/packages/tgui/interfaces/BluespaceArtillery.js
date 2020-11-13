import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Flex, ProgressBar, Slider } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';

const POWER_MUL = 1e3;

export const BluespaceArtillery = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacityPercent,
    shotPower,
    inputAttempt,
    inputting,
    inputLevel,
    inputLevelMax,
    inputAvailable,
    notice,
    connected,
    unlocked,
    target,
  } = data;
  const inputState = (
    capacityPercent >= 100 && 'good'
    || inputting && 'average'
    || 'bad'
  );
  return (
    <Window
      width={340}
      height={425}>
      <Window.Content>
        {!!notice && (
          <NoticeBox>
            {notice}
          </NoticeBox>
        )}
        {connected ? (
          <Fragment>
            <Section title="Stored Energy">
              <ProgressBar
                value={capacityPercent * 0.01}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.15, 0.5],
                  bad: [-Infinity, 0.15],
                }} />
            </Section>
            <Section title="Input">
              <LabeledList>
                <LabeledList.Item
                  label="Charge Mode"
                  buttons={
                    <Button
                      icon={inputAttempt ? 'sync-alt' : 'times'}
                      selected={inputAttempt}
                      onClick={() => act('tryinput')}>
                      {inputAttempt ? 'Auto' : 'Off'}
                    </Button>
                  }>
                  <Box color={inputState}>
                    {capacityPercent >= 100 && 'Fully Charged'
                      || inputting && 'Charging'
                      || 'Not Charging'}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Target Input">
                  <Flex inline width="100%">
                    <Flex.Item>
                      <Button
                        icon="fast-backward"
                        disabled={inputLevel === 0}
                        onClick={() => act('input', {
                          target: 'min',
                        })} />
                      <Button
                        icon="backward"
                        disabled={inputLevel === 0}
                        onClick={() => act('input', {
                          adjust: -10000,
                        })} />
                    </Flex.Item>
                    <Flex.Item grow={1} mx={1}>
                      <Slider
                        value={inputLevel / POWER_MUL}
                        fillValue={inputAvailable / POWER_MUL}
                        minValue={0}
                        maxValue={inputLevelMax / POWER_MUL}
                        step={5}
                        stepPixelSize={4}
                        format={value => formatPower(value * POWER_MUL, 1)}
                        onDrag={(e, value) => act('input', {
                          target: value * POWER_MUL,
                        })} />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="forward"
                        disabled={inputLevel === inputLevelMax}
                        onClick={() => act('input', {
                          adjust: 10000,
                        })} />
                      <Button
                        icon="fast-forward"
                        disabled={inputLevel === inputLevelMax}
                        onClick={() => act('input', {
                          target: 'max',
                        })} />
                    </Flex.Item>
                  </Flex>
                </LabeledList.Item>
                <LabeledList.Item label="Available">
                  {formatPower(inputAvailable)}
                </LabeledList.Item>
                <LabeledList.Item label="Explosion Power">
                  {shotPower}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section
              title="Target"
              buttons={(
                <Button
                  icon="crosshairs"
                  disabled={!unlocked}
                  onClick={() => act('recalibrate')} />
              )}>
              <Box
                color={target ? 'average' : 'bad'}
                fontSize="25px">
                {target || 'No Target Set'}
              </Box>
            </Section>
            <Section>
              {unlocked ? (
                <Box style={{ margin: 'auto' }}>
                  <Button
                    fluid
                    content="FIRE"
                    color="bad"
                    disabled={!target}
                    fontSize="30px"
                    textAlign="center"
                    lineHeight="46px"
                    onClick={() => act('fire')} />
                </Box>
              ) : (
                <Fragment>
                  <Box
                    color="bad"
                    fontSize="18px">
                    Bluespace artillery is currently locked.
                  </Box>
                  <Box mt={1}>
                    Awaiting authorization via keycard reader from at minimum
                    two station heads.
                  </Box>
                </Fragment>
              )}
            </Section>
          </Fragment>
        ) : (
          <Section>
            <LabeledList>
              <LabeledList.Item label="Maintenance">
                <Button
                  icon="wrench"
                  content="Complete Deployment"
                  onClick={() => act('build')} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
