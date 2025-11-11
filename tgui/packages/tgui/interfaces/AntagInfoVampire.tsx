import { BooleanLike } from 'common/react';
import { sanitizeText } from 'tgui/sanitize';
import { DmIcon } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type VampireInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  powers: PowerInfo[];
};

type ClanInfo = {
  name: string;
  description: string;
  icon: string;
  icon_state: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
  icon_state: string;
  cost: string;
  constant_cost: string;
  cooldown: string;
};

type Info = {
  objectives: Objective[];
};

export const AntagInfoVampire = (_props) => {
  const [tab, setTab] = useLocalState('tab', 1);
  return (
    <Window width={620} height={800} theme="spooky">
      <Window.Content>
        <Tabs>
          <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
            Basics
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
            General Guide
          </Tabs.Tab>
          <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
            Powers
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <VampireIntroduction />}
        {tab === 2 && <VampireGuide />}
        {tab === 3 && <PowerSection />}
      </Window.Content>
    </Window>
  );
};

const VampireIntroduction = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <AntagInfoHeader name={'Vampire'} asset="vampire.png" />
      </Stack.Item>
      <Stack.Item grow maxHeight="200px">
        <ObjectivesSection objectives={objectives} />
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

const VampireGuide = (_props) => {
  const { data } = useBackend<VampireInformation>();
  const { clan } = data;

  const [tab, setTab] = useLocalState('guideTab', 1);
  return (
    <Section title="Guide">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab
              icon="list"
              selected={tab === 1}
              onClick={() => setTab(1)}
            >
              The Basics
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 2}
              onClick={() => setTab(2)}
            >
              The Masquerade
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 3}
              onClick={() => setTab(3)}
            >
              Humanity
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 4}
              onClick={() => setTab(4)}
            >
              Vampire Society
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 5}
              onClick={() => setTab(5)}
            >
              Sol
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 6}
              onClick={() => setTab(6)}
            >
              Strengths
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 7}
              onClick={() => setTab(7)}
            >
              Weaknesses
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 8}
              onClick={() => setTab(8)}
            >
              Vitae
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 9}
              onClick={() => setTab(9)}
            >
              Disciplines
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 10}
              onClick={() => setTab(10)}
            >
              Your Haven
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 11}
              onClick={() => setTab(11)}
            >
              Structures
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 12}
              onClick={() => setTab(12)}
            >
              Ghouls
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          {tab === 1 && (
            // The Basics
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                So you&apos;re immortal. Very cool.
              </Box>
              <Box fontSize="30px" textColor="Red" bold>
                Now shut up about it.
              </Box>
              <br />
              No seriously. As a vampire(we call them kindred), one of the first
              things you need to know is that there is a reason everyone thinks
              they&apos;re fairytales. Nobody wants to accept that they&apos;re
              just pray animals for another race, and humans are very easy to
              get skittish.
              <br />
              <br />
              <b>
                The reason we&apos;ve lived this long is because we have kept
                quiet.
              </b>
              <br />
              <br />
              <Box inline fontSize="16px" textColor="red">
                <b>
                  You <i>will</i> want to keep it that way.
                </b>
              </Box>{' '}
              <br />
              <br />
              <Box fontSize="20px" textColor="gold" bold>
                Fitting in with the mortals
              </Box>
              <br />
              Right away there are some things to keep track of: You are dead.
              Very dead. This means you do not need to breathe, eat, or sleep.
              <Box inline textColor="red">
                <b>You also do not have a heartbeat.</b>
              </Box>{' '}
              So try to avoid any stray medical scans as best you can.
              <br />
              <br />
              Aside from any scan-happy doctors, your greatest fear should be
              <b> the curator.</b> They know vampires are real. And have a very
              nice little book that they can use to{' '}
              <Box inline textColor="red">
                <b>
                  instantly confirm you as kindred, so: Stay. The. Fuck. Away.
                </b>
              </Box>{' '}
              <br /> <br />
              <Box fontSize="20px" textColor="green" bold>
                Your Hud & First Steps
              </Box>
              <br />
              See the new fancy hud icons on the left of the screen? You can
              click on them. They tell you things.
              <br /> <br />
              <Box fontSize="13px" textColor="red" bold>
                Aside from that, your best bet right now is to find another
                kindred and ask them for help. Maybe they even know the local
                prince.
              </Box>
              <br />
              <Box fontSize="20px" textColor="darkred" bold>
                Growing in power
              </Box>
              <br />
              At the end of each{' '}
              <Box inline textColor="yellow">
                Sol
              </Box>{' '}
              you gain a new Rank. Ranking up increases your total strength,
              health, feed rate, and blood capacity.
              <br /> <br />
              Alongside this, you also gain a point to spend on a discipline.
              These powers are essential to surviving.
            </Box>
          )}
          {tab === 2 && (
            // The Masquerade
            <Box>
              <Box fontSize="20px" textColor="gold" bold>
                The Masquerade and you.
              </Box>
              <Box fontSize="11px" textColor="gold" bold>
                Or:
              </Box>
              <Box fontSize="15px" textColor="gold" bold>
                How to keep from getting us all killed.
              </Box>
              <br />
              The most important rule of the Kindred is maintaining the{' '}
              <Box inline textColor="gold">
                Masquerade.
              </Box>{' '}
              If a person that is not apart of the Kindred witnesses you doing
              anything out of the ordinary at all, you will recieve a{' '}
              <Box inline textColor="red">
                Masquerade Infraction.
              </Box>
              <br /> <br />
              You will be allowed <b>three</b>{' '}
              <Box inline textColor="red">
                Masquerade Infractions
              </Box>{' '}
              before you are exiled from the Kindred and <b>all</b> vampires
              turn against you.
              <br /> <br />
              The {"curator's "}
              <Box inline textColor="blue">
                Archive of the Kindred
              </Box>{' '}
              can instantly reveal your true identity if used on you with your{' '}
              <Box inline textColor="gold">
                Masquerade Ability
              </Box>{' '}
              disabled.
              <br /> <br /> Same for doctors and their pesky health analyzers.
              They can quite easily tell you are dead. Do not get caught!
            </Box>
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const PowerSection = (_props) => {
  const { data } = useBackend<VampireInformation>();
  const { powers } = data;
  if (!powers) {
    return <Section minHeight="220px" />;
  }

  const [tab, setTab] = useLocalState('powerTab', 0);
  return (
    <Section title="Powers">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            {powers.map((power, index) => (
              <Tabs.Tab
                key={index}
                selected={tab === index}
                onClick={() => setTab(index)}
              >
                <Stack align="center">
                  <Stack.Item>
                    <DmIcon
                      inline
                      icon={power.icon}
                      icon_state={power.icon_state}
                      fallback={
                        <Icon mr={1} name="spinner" spin fontSize="30px" />
                      }
                      width="32px"
                      style={{
                        imageRendering: 'pixelated',
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>{power.name}</Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          {powers.map(
            (power, index) =>
              tab === index && (
                <Box key={index}>
                  <Box inline bold textColor="red">
                    {power.cost !== '0' && <>BLOOD COST: {power.cost}</>}
                    {power.cost !== '0' && power.constant_cost !== '0' && (
                      <br />
                    )}
                    {power.constant_cost !== '0' && (
                      <>BLOOD DRAIN: {power.constant_cost}</>
                    )}
                    {(power.cost !== '0' || power.constant_cost !== '0') &&
                      power.cooldown !== '0' && (
                        <>
                          <br />
                          <br />
                        </>
                      )}
                    {power.cooldown !== '0' && (
                      <>
                        COOLDOWN: {power.cooldown} seconds
                        <br />
                        <br />
                      </>
                    )}
                  </Box>
                  <Box
                    style={{ whiteSpace: 'pre-wrap', lineHeight: '1' }}
                    dangerouslySetInnerHTML={{
                      __html: sanitizeText(
                        power.explanation.replace(/\n/g, '\n\n'),
                      ),
                    }}
                  />
                </Box>
              ),
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ClanSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Section title="Clan">
        <Stack vertical>
          <Stack.Item fontSize="20px">
            <Box inline textColor="red">
              You are not in a clan!
            </Box>
          </Stack.Item>
          <Stack.Item>
            To determine your clan, utilize the clan selection ability.
          </Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Section title="Clan">
      {clan.map((ClanInfo, index) => (
        <Stack key={index}>
          <Stack.Item>
            <DmIcon
              icon={ClanInfo.icon}
              icon_state={ClanInfo.icon_state}
              fallback={<Icon mr={1} name="spinner" spin fontSize="30px" />}
              width="128px"
              style={{
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Stack.Item textAlign="center">
              <Box inline fontSize="20px" textColor="red">
                You are part of the <b>{ClanInfo.name}!</b>
              </Box>
            </Stack.Item>
            <Box
              fontSize="16px"
              dangerouslySetInnerHTML={{ __html: ClanInfo.description }}
            />
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
