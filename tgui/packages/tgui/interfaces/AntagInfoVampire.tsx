import { resolveAsset } from '../assets';
import { BooleanLike } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Divider, Dropdown, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { ObjectivesSection, Objective } from './common/ObjectiveSection';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type VampireInformation = {
  clan: ClanInfo[];
  in_clan: BooleanLike;
  powers: PowerInfo[];
};

type ClanInfo = {
  clan_name: string;
  clan_description: string;
  clan_icon: string;
};

type PowerInfo = {
  name: string;
  explanation: string;
  icon: string;
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
    <Window width={620} height={900} theme="syndicate">
      <Window.Content>
        <Tabs>
          <Tabs.Tab icon="list" selected={tab === 1} onClick={() => setTab(1)}>
            Basics
          </Tabs.Tab>
          <Tabs.Tab icon="list" selected={tab === 2} onClick={() => setTab(2)}>
            Powers
          </Tabs.Tab>
        </Tabs>
        {tab === 1 && <VampireIntroduction />}
        {tab === 2 && <PowerSection />}
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
        <AntagInfoHeader name={'Vampire'} asset="traitor.png" />
      </Stack.Item>
      <Stack.Item grow maxHeight="150px">
        <ObjectivesSection objectives={objectives} />
      </Stack.Item>
      <Stack.Item>
        <VampireGuide />
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

const VampireGuide = (_props) => {
  const [tab, setTab] = useLocalState('guideTab', 1);
  return (
    <Section title="Guide">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab icon="list" selected={tab === 1} onClick={() => setTab(1)}>
              The Basics
            </Tabs.Tab>
            <Tabs.Tab icon="list" selected={tab === 2} onClick={() => setTab(2)}>
              Blood
            </Tabs.Tab>
            <Tabs.Tab icon="list" selected={tab === 3} onClick={() => setTab(3)}>
              Masquerade
            </Tabs.Tab>
            <Tabs.Tab icon="list" selected={tab === 4} onClick={() => setTab(4)}>
              Sol
            </Tabs.Tab>
            <Tabs.Tab icon="list" selected={tab === 5} onClick={() => setTab(5)}>
              Your Lair
            </Tabs.Tab>
            <Tabs.Tab icon="list" selected={tab === 6} onClick={() => setTab(6)}>
              Vassals
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          {tab === 1 && (
            // The Basics
            <Box>
              As a vampire, you are a creature of the night, free from the weaknesses of mortals yet bound by your own.
              <br /> <br />
              <Box fontSize="20px" textColor="blue">
                Your Strengths:
              </Box>
              <br />
              <Box textColor="purple">Enhanced Senses</Box>Night vision and heat vision allow you to track prey and navigate the
              shadows with ease.
              <br /> <br />
              <Box textColor="blue">Undead Physiology</Box>You do not breathe, have no heartbeat, and cannot be affected by
              sleep or illness.
              <br /> <br />
              <Box textColor="darkgreen">Resilience</Box>The cold and radiation mean nothing to you. You cannot take toxin
              damage, and even critical injuries will not knock you down.
              <br /> <br />
              <Box textColor="pink">Immense Strength</Box>As a vampire, your primary weapons are your hands. Each time you rank
              up so does the damage that your fists deal.
              <br /> <br />
              <Box fontSize="20px" textColor="red">
                Your Weaknesses:
              </Box>
              <br />
              <Box textColor="red">Stakes</Box>A stake to the heart will paralyze you, disabling powers, halting all healing and
              preventing revival.
              <br /> <br />
              <Box textColor="orange">Sol</Box>A stake to the heart will paralyze you, disabling powers, halting all healing and
              preventing revival.
              <br /> <br />
              <Box textColor="gold">The Masquerade</Box>Being discovered as a vampire can lead to ruin. If your secret is
              exposed, other vampires will turn against you and steal your vassals.
              <br /> <br />
            </Box>
          )}
          {tab === 2 && (
            // Blood
            <Box>
              As an undead predator, you constantly feel the pull of{' '}
              <Box inline textColor="red">
                Hunger.
              </Box>{' '}
              Feeding is not just a luxury. <i>It is a necessity.</i> As your blood reaches zero you will slowly feel the side
              effects, such as blurry vision and impaired healing.
              <br /> <br />
              When you finally deplete nearly all your blood you will enter a{' '}
              <Box inline textColor="purple">
                Frenzy.
              </Box>{' '}
              You become ravenous and able to instantly aggressively grab people. You cannot use any items that require
              dexterity and lose access to all vampiric powers except{' '}
              <Box inline textColor="red">
                Feed
              </Box>{' '}
              and{' '}
              <Box inline textColor="blue">
                Trespass
              </Box>
              <br />
              You will exit your frenzy after consuming{' '}
              <Box inline textColor="red">
                250 Blood.
              </Box>
            </Box>
          )}
          {tab === 3 && (
            // Masquerade
            <Box>
              The only rule of the Kindred is maintaining the{' '}
              <Box inline textColor="gold">
                Masquerade.
              </Box>{' '}
              If an un-enlightened crewmember witnesses you feeding, you will recieve a
              <Box inline textColor="red">
                Masquerade Infraction.
              </Box>
              <br /> <br />
              You will be allowed <b>three</b>{' '}
              <Box inline textColor="red">
                Masquerade Infractions
              </Box>{' '}
              before you officially break the Masquerade and are exiled from the Kindred.
              <br /> <br />
              The {"curator's "}
              <Box inline textColor="blue">
                Archive of the Kindred
              </Box>{' '}
              can instantly reveal your true identity if used on you with your <i>Masquerade Ability</i> disabled.
            </Box>
          )}
          {tab === 4 && (
            // Sol
            <Box>
              Every <i>10 minutes</i>,{' '}
              <Box inline textColor="orange">
                Sol
              </Box>{' '}
              arrives, bathing the station in light for <i>1 minute</i>. If you are not in a coffin or closet, you will burn.
              <br /> <br />
              The end of each{' '}
              <Box inline textColor="orange">
                Sol
              </Box>{' '}
              grants you the opportunity to rank up in your coffin. Ranking up will increase your strength, health, blood
              capacity, and power capabilities.
            </Box>
          )}
          {tab === 5 && (
            // Lair
            <Box>
              Every vampire requires a lair. Whether it be in maintenance or the {"captain's"} bedroom, this is where you will
              vassalize the crew and get up to other evil deeds.
              <br /> <br />
              To claim a lair you must bring a coffin to any room and rest inside of it. You can obtain a coffin in one of 3
              primary ways:
              <br /> <br />
              Make one in the{' '}
              <Box inline textColor="blue">
                Crafting Menu
              </Box>{' '}
              under the{' '}
              <Box inline textColor="blue">
                Structures
              </Box>{' '}
              Category
              <br />
              The{' '}
              <Box inline textColor="yellow">
                Chapel
              </Box>{' '}
              often contains coffins
              <br />
              Coffins can rarely spawn in{' '}
              <Box inline textColor="green">
                Maintenance
              </Box>
            </Box>
          )}
          {tab === 6 && (
            // Vassals
            <Box>
              A {"vampire's"} true strength lies in their ability to vassalize the crew.
              <br /> <br />
              Crewmembers can be vassalized by building a{' '}
              <Box inline textColor="purple">
                Persuasion Rack
              </Box>
              , securing it in your lair, attaching your victim, and <i>persuading</i> them. Vassals can only be deconverted by
              way of{' '}
              <Box inline textColor="red">
                Mindshield.
              </Box>
              <br /> <br />
              It <b>is</b> possible for{' '}
              <Box inline textColor="red">
                Mindshielded
              </Box>{' '}
              crewmembers to be vassalized if their mind is weak enough. It is impossible to convert servants of eldritch gods
              however.
              <br /> <br />
              Additionally, you can promote <b>one</b> vassal into a{' '}
              <Box inline textColor="blue">
                Favorite Vassal
              </Box>
              , which will gain powers unique to the Clan that you have chosen.
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
              <Tabs.Tab key={index} selected={tab === index} onClick={() => setTab(index)}>
                <Stack align="center">
                  <Stack.Item>
                    <Box
                      inline
                      as="img"
                      src={resolveAsset(`${power.icon}.png`)}
                      width="32px"
                      style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated' }}
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
                    {power.cost !== '0' && (
                      <>
                        BLOOD COST: {power.cost}
                        <br />
                      </>
                    )}
                    {power.constant_cost !== '0' && (
                      <>
                        BLOOD DRAIN: {power.constant_cost}
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
                  <Box style={{ whiteSpace: 'pre-wrap' }}>{power.explanation}</Box>
                </Box>
              )
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const ClanSection = (props: any) => {
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
          <Stack.Item>To enter a clan you must first claim a lair by sleeping in a coffin.</Stack.Item>
        </Stack>
      </Section>
    );
  }

  return (
    <Section title="Clan">
      <Stack>
        <Stack.Item>
          {clan.map((ClanInfo) => (
            <>
              <Stack.Item fontSize="20px" textAlign="center">
                <Box
                  inline
                  as="img"
                  src={resolveAsset(`${ClanInfo.clan_icon}.png`)}
                  width="128px"
                  style={{ msInterpolationMode: 'nearest-neighbor', imageRendering: 'pixelated', float: 'left' }}
                />
                <Box inline textColor="red">
                  You are part of the {ClanInfo.clan_name}!
                </Box>
              </Stack.Item>
              <Stack.Item fontSize="16px">
                <br />
                {ClanInfo.clan_description}
              </Stack.Item>
            </>
          ))}
        </Stack.Item>
      </Stack>
    </Section>
  );
};
