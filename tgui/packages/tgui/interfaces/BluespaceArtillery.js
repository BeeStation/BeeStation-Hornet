import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';

export const BluespaceArtillery = (props, context) => {
  const { act, data } = useBackend(context);
  const { notice, connected, unlocked, target, charge, max_charge, formatted_charge, targets } = data;
  return (
    <Window width={600} height={280}>
      <Window.Content>
        {!!notice && <NoticeBox>{notice}</NoticeBox>}
        {connected ? (
          <Stack>
            <Stack.Item grow={1}>
              <Section title="Charge">
                <ProgressBar
                  animated
                  step={1}
                  minValue={0}
                  maxValue={max_charge}
                  value={charge}
                  ranges={{
                    good: [max_charge, Infinity],
                    average: [max_charge * 0.2, max_charge * 0.99],
                    bad: [-Infinity, max_charge * 0.2],
                  }}>
                  {formatted_charge}
                </ProgressBar>
              </Section>
              <Section title="Target">
                <Box color={target ? 'average' : 'bad'} fontSize="25px">
                  {target ? target[1] : 'No Target Set'}
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
                      onClick={() => target && act('fire')}
                    />
                  </Box>
                ) : (
                  <>
                    <Box color="bad" fontSize="18px">
                      Bluespace artillery is currently locked.
                    </Box>
                    <Box mt={1}>Awaiting authorization via keycard reader from at minimum two station heads.</Box>
                  </>
                )}
              </Section>
            </Stack.Item>
            <Stack.Item width="200px">
              <Section title="Available Targets" height="100%" scrollable fill>
                <Box height="100%">
                  {Object.entries(targets || {}).map(([key, value], index) => (
                    <Box key={`${key}-${index}`} mb={1}>
                      <Button
                        fluid
                        color={target && key === target[0] ? 'bad' : 'blue'}
                        content={value}
                        onClick={() => act('set_target', { target: key })}
                      />
                    </Box>
                  ))}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        ) : (
          <Section>
            <Box>
              <Button icon="wrench" content="Complete Deployment" onClick={() => act('build')} />
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
