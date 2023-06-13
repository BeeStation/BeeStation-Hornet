import { sortBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { Box, Flex, ProgressBar, Stack, Tabs, Section, Table } from '../components';
import { Window } from '../layouts';

const JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED = 1;
const JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS = 2;

const sortByPlaytime = sortBy(([_, playtime]) => -playtime);

const PlaytimeSection = (props) => {
  const { playtimes } = props;
  const sortedPlaytimes = sortByPlaytime(Object.entries(playtimes));
  const mostPlayed = sortedPlaytimes[0][1];
  return (
    <Table>
      {sortedPlaytimes.map(([jobName, playtime]) => {
        const ratio = playtime / mostPlayed;
        return (
          <Table.Row key={jobName}>
            <Table.Cell
              collapsing
              p={0.5}
              style={{
                'vertical-align': 'middle',
              }}>
              <Box align="right">{jobName}</Box>
            </Table.Cell>
            <Table.Cell>
              <ProgressBar maxValue={mostPlayed} value={playtime}>
                <Flex>
                  <Flex.Item width={`${ratio * 100}%`} />
                  <Flex.Item>
                    {(playtime / 60).toLocaleString(undefined, {
                      'minimumFractionDigits': 1,
                      'maximumFractionDigits': 1,
                    })}
                    h
                  </Flex.Item>
                </Flex>
              </ProgressBar>
            </Table.Cell>
          </Table.Row>
        );
      })}
    </Table>
  );
};

export const TrackedPlaytime = (props, context) => {
  const { data } = useBackend(context);
  const {
    failReason,
    jobPlaytimes,
    antagPlaytimes,
    specialPlaytimes,
    outdatedPlaytimes,
    livingTime,
    deadTime,
    observerTime,
    ghostTime,
  } = data;
  const SCREEN_MODE_JOB = 1;
  const SCREEN_MODE_ANTAG = 2;
  const SCREEN_MODE_SPECIAL = 3;
  const SCREEN_MODE_DEPRECATED = 4;
  const [screenmode, setScreenmode] = useSharedState(context, 'tab_main', SCREEN_MODE_JOB);
  return (
    <Window title="Tracked Playtime" width={550} height={650}>
      <Window.Content scrollable>
        {(failReason &&
          ((failReason === JOB_REPORT_MENU_FAIL_REASON_TRACKING_DISABLED && <Box>This server has disabled tracking.</Box>) ||
            (failReason === JOB_REPORT_MENU_FAIL_REASON_NO_RECORDS && <Box>You have no records.</Box>))) || (
          <Box>
            <Section title="Total">
              <PlaytimeSection
                playtimes={{
                  'Living': livingTime,
                  'Dead': deadTime,
                  'Observing': observerTime,
                  '(Old) Ghost': ghostTime,
                }}
              />
            </Section>
            <Stack fill vertical>
              {
                <Stack.Item>
                  <Tabs fluid textAlign="center">
                    <Tabs.Tab
                      color="Blue"
                      selected={screenmode === SCREEN_MODE_JOB}
                      onClick={() => setScreenmode(SCREEN_MODE_JOB)}>
                      Station Job Roles
                    </Tabs.Tab>
                    <Tabs.Tab
                      Color="Orange"
                      selected={screenmode === SCREEN_MODE_ANTAG}
                      onClick={() => setScreenmode(SCREEN_MODE_ANTAG)}>
                      Antagonist Roles
                    </Tabs.Tab>
                    <Tabs.Tab
                      Color="Green"
                      selected={screenmode === SCREEN_MODE_SPECIAL}
                      onClick={() => setScreenmode(SCREEN_MODE_SPECIAL)}>
                      Special Roles
                    </Tabs.Tab>
                    <Tabs.Tab
                      Color="Red"
                      selected={screenmode === SCREEN_MODE_DEPRECATED}
                      onClick={() => setScreenmode(SCREEN_MODE_DEPRECATED)}>
                      Deprecated Roles
                    </Tabs.Tab>
                  </Tabs>
                </Stack.Item>
              }
            </Stack>
            {screenmode === SCREEN_MODE_JOB && (
              <Section title="Jobs">
                <PlaytimeSection playtimes={jobPlaytimes} />
              </Section>
            )}
            {screenmode === SCREEN_MODE_ANTAG && (
              <Section title="Antagonists">
                <PlaytimeSection playtimes={antagPlaytimes} />
              </Section>
            )}
            {screenmode === SCREEN_MODE_SPECIAL && (
              <Section title="Special">
                <PlaytimeSection playtimes={specialPlaytimes} />
              </Section>
            )}
            {screenmode === SCREEN_MODE_DEPRECATED && (
              <Section title="Deprecated roles">
                <PlaytimeSection playtimes={outdatedPlaytimes} />
              </Section>
            )}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
