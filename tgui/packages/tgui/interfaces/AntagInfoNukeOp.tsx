import { useBackend } from '../backend';
import { Box, BlockQuote, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  antag_name: string;
  nuke_code: string;
  leader: BooleanLike;
  lone: BooleanLike;
};

const MissionNormal = (_props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <BlockQuote>
      <p>
        Your mission is simple, blow up the station. To achieve this your team must get the Nuclear Authentification Disk. Once
        you have the disk, it&apos;s only a matter of getting the nuke aboard the station, arming it, starting the timer, and
        then getting out before it pulverizes you in its blast.
      </p>
      {(!!data.leader && (
        <p>
          You have been made the leader of this mission, you must coordinate with your team and devise a strategy. If you are
          not up to the task, you can trade your leader ID card with another team member.
        </p>
      )) || (
        <p>
          Coordination is key, which is why you have been assigned a leader to guide the mission. Listen to them and you&apos;re
          bound to succeed.
        </p>
      )}
    </BlockQuote>
  );
};

const MissionLone = (_props, _context) => {
  return (
    <BlockQuote>
      <p>
        You have been sent on a solo nuclear mission. The reason you were sent alone is unclear, but your mission is to get the
        Nuclear Authentification Disk and activate the station&apos;s self-destruct device.
      </p>
    </BlockQuote>
  );
};

const MissionSection = (_props, context) => {
  const { data } = useBackend<Info>(context);
  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Section title="Mission">{(!data.lone && <MissionNormal />) || <MissionLone />}</Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Section>
                <Box
                  inline
                  as="img"
                  src={resolveAsset('nuke.png')}
                  width="64px"
                  style={{ '-ms-interpolation-mode': 'nearest-neighbor', 'float': 'left' }}
                />
                <b>Nuke Code</b>: {data.nuke_code}
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Section title="Uplink">
                You have a{' '}
                <Box inline textColor="red">
                  syndicate uplink
                </Box>{' '}
                in your pocket, in the form of a radio.
                <br />
                This uplink allows you to buy a variety of gear to use on your mission.
                <br />
                Use your telecrystals wisely whenever buying gear!
              </Section>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <Section title="Nuking 101">
                <Box className="candystripe">
                  <b>1</b>) Insert disk into nuke.
                </Box>
                <Box className="candystripe">
                  <b>2</b>) Turn off the safety.
                </Box>
                <Box className="candystripe">
                  <b>3</b>) Set a timer on the nuke (minimum of 90 seconds).
                </Box>
                <Box className="candystripe">
                  <b>4</b>) Unanchor nuke.
                </Box>
                <Box className="candystripe">
                  <b>5</b>) Drag nuke to station.
                </Box>
                <Box className="candystripe">
                  <b>6</b>) Anchor nuke on station (not in space!)
                </Box>
                <Box className="candystripe">
                  <b>7</b>) Activate nuke.
                </Box>
                <Box className="candystripe">
                  <b>8</b>) Eject disk from nuke and take it.
                </Box>
                <Box className="candystripe">
                  <b>9</b>) Get out of the blast radius — return to the base with your fellow nukies!
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const AntagInfoNukeOp = (_props, context) => {
  const { data } = useBackend<Info>(context);
  const { antag_name } = data;
  return (
    <Window width={620} height={620} theme="syndicate">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={antag_name || 'Nuclear Operative'} asset="nukie.png" />
          </Stack.Item>
          <Stack.Item>
            <MissionSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
