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
    <Window width={620} height={700} theme="spooky">
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
      <Stack.Item grow maxHeight="150px">
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
              Strengths & Weaknesses
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 3}
              onClick={() => setTab(3)}
            >
              Blood & Powers
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 4}
              onClick={() => setTab(4)}
            >
              Masquerade
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
              Your Lair
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 7}
              onClick={() => setTab(7)}
            >
              Structures
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 8}
              onClick={() => setTab(8)}
            >
              Vassals
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          {tab === 1 && (
            // The Basics
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                Creating a Lair
              </Box>
              <br />
              As a vampire, one of the first things you should do is set up a
              Lair. Ideally this should be located somewhere that nobody will{' '}
              <b>ever</b> wander into. Some good locations can include:{' '}
              <i>
                a hidden room in maintenance, a backroom in your department, or
                simply a dorms cabin
              </i>
              . Get creative!
              <br /> <br />
              To claim a lair, bring a coffin to your desired location and rest
              in it.
              <br /> <br />
              <Box fontSize="20px" textColor="gold" bold>
                Vassalizing the Crew
              </Box>
              <br />
              Sooner or later you are going to want to vassalize the crew.
              However, before you do so, you need to build a{' '}
              <Box inline textColor="purple">
                Persuasion Rack
              </Box>{' '}
              with{' '}
              <Box inline textColor="red">
                Fleshy Mass.
              </Box>{' '}
              This is obtained by using your{' '}
              <Box inline textColor="red">
                Vampiric Conversion
              </Box>{' '}
              power with iron in-hand to transform it into {"it's"} vampiric
              counterpart.
              <br /> <br />
              <Box inline textColor="purple">
                Persuasion Racks
              </Box>{' '}
              are what you will be using to convert crewmembers into your
              vassals. To use a{' '}
              <Box inline textColor="purple">
                Persuasion Rack
              </Box>{' '}
              you must first capture a subject and restrain them. After this,
              drag them onto the rack and torture them by clicking on the rack.{' '}
              <b>
                Torturing someone with a better tool will make the process
                faster!
              </b>
              <br /> <br />
              <Box fontSize="20px" textColor="green" bold>
                Ranking Up
              </Box>
              <br />
              At the end of each{' '}
              <Box inline textColor="yellow">
                Sol
              </Box>{' '}
              you gain a new Rank. Ranking up increases your total strength,
              health, feed rate, and blood capacity.
              <br /> <br />
              Alongside this, you also gain a new power to pick in your coffin.
              These powers are essential to surviving and vassalizing the crew.
            </Box>
          )}
          {tab === 2 && (
            // Strengths and Weaknesses
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                Your Strengths
              </Box>
              <br />
              <Box textColor="purple">Enhanced Senses</Box>Night and heat vision
              allow you to track prey and navigate the shadows with ease.
              <br /> <br />
              <Box textColor="blue">Undead Physiology</Box>You do not breathe,
              have no heartbeat, and cannot be affected by sleep or illness.
              Injuries that would normally kill mortals only put you into{' '}
              <Box inline textColor="orange">
                Torpor.
              </Box>{' '}
              Given you have enough{' '}
              <Box inline textColor="red">
                blood
              </Box>{' '}
              and are not staked you will <i>eventually</i> arise from your
              fatal wounds.
              <br /> <br />
              <Box textColor="green">Resilience</Box>The cold and radiation mean
              nothing to you. You cannot take toxin damage, and critical
              injuries will not knock you down.
              <br /> <br />
              <Box textColor="pink">Immense Strength</Box>As a vampire, your
              primary weapons are your fists. Every time you rank up, the damage
              done by your fists increases.
              <br /> <br />
              <Box fontSize="20px" textColor="red" bold>
                Your Weaknesses
              </Box>
              <br />
              <Box textColor="red">Stakes</Box>A stake to the heart will
              paralyze you, disable powers, halt all healing, and prevent your
              revival.
              <br /> <br />
              <Box textColor="orange">Sol</Box>Every <b>10 minutes</b> Sol will
              bathe the station in sunlight, severely hindering you unless in a
              coffin.
              <br /> <br />
              <Box textColor="gold">The Masquerade</Box>All vampires swear an
              oath to maintain their secrecy and vampirism. If you break this
              oath, other vampires will turn against you.
              <br /> <br />
            </Box>
          )}
          {tab === 3 && (
            // Blood & Powers
            <Box>
              <Box fontSize="20px" textColor="red" bold>
                Blood Drain
              </Box>
              <br />
              As an undead vampire, you constantly feel the pull of{' '}
              <Box inline textColor="red">
                Hunger.
              </Box>{' '}
              Feeding is not just a luxury. <b>It is a necessity.</b> As your
              blood reaches zero you will slowly feel the side-effects, such as
              blurry vision and impaired healing.
              <br /> <br />
              You can gain{' '}
              <Box inline textColor="red">
                blood
              </Box>{' '}
              from any of four ways:
              <Box px={2}>
                <i>
                  Your fellow crewmembers <br /> Monkeys <br /> Mice <br />{' '}
                  Blood bags
                </i>
              </Box>
              <br />
              <Box fontSize="20px" textColor="orange" bold>
                Entering a Frenzy
              </Box>
              <br />
              If you ever deplete all of your blood you will enter a{' '}
              <Box inline textColor="orange">
                Frenzy.
              </Box>{' '}
              Your vision turns to blood while you become deaf and mute, lose
              access to most powers, and slowly take burn damage. However, you
              will become ravenous with the ability to instantly aggressively
              grab people.
              <br /> <br />
              After consuming{' '}
              <Box inline textColor="red">
                250 Blood
              </Box>{' '}
              you will exit the{' '}
              <Box inline textColor="orange">
                Frenzy
              </Box>{' '}
              and return to your previous self.
              <br /> <br />
              <Box fontSize="20px" textColor="blue" bold>
                Powers
              </Box>
              <br />
              All powers cost{' '}
              <Box inline textColor="red">
                blood.
              </Box>{' '}
              Some powers can be toggled and drain{' '}
              <Box inline textColor="red">
                blood
              </Box>{' '}
              while active. Other powers simply remove their cost in{' '}
              <Box inline textColor="red">
                blood
              </Box>{' '}
              immediately after use.
              <br /> <br />
              Detailed information on each of the{' '}
              <Box inline textColor="blue">
                Powers
              </Box>{' '}
              you have unlocked can be found under the{' '}
              <Box inline textColor="blue">
                Powers Tab
              </Box>{' '}
              in the top of this window.
            </Box>
          )}
          {tab === 4 && (
            // Masquerade
            <Box>
              <Box fontSize="20px" textColor="gold" bold>
                The Masquerade
              </Box>
              <br />
              The only rule of the Kindred is maintaining the{' '}
              <Box inline textColor="gold">
                Masquerade.
              </Box>{' '}
              If a person that is not apart of the Kindred witnesses you
              feeding, you will recieve a{' '}
              <Box inline textColor="red">
                Masquerade Infraction.
              </Box>
              <br /> <br />
              You will be allowed <b>three</b>{' '}
              <Box inline textColor="red">
                Masquerade Infractions
              </Box>{' '}
              before you are exiled from the Kindred and all vampires turn
              against you.
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
            </Box>
          )}
          {tab === 5 && (
            // Sol
            <Box>
              <Box fontSize="20px" textColor="orange" bold>
                Sol
              </Box>
              <br />
              Every <b>10 minutes</b>,{' '}
              <Box inline textColor="orange">
                Sol
              </Box>{' '}
              arrives, bathing the station in light for <b>1 minute</b>. While
              this occurs, you recieve debuffs:
              <br /> <br />
              <Box textColor="red">Hindered Healing</Box>
              You lose the ability to passively heal unless inside a{' '}
              <Box inline textColor="blue">
                Coffin
              </Box>{' '}
              and take 50% more damage.
              <br /> <br />
              <Box textColor="blue">Impaired Powers</Box>
              All powers take <b>twice</b> their usual cooldown, most powers
              take more{' '}
              <Box inline textColor="red">
                Blood
              </Box>{' '}
              to use and maintain, and other powers are completely blocked.
              {!clan.some((c) => c.name === 'Tremere Clan') && (
                <>
                  <br /> <br />
                  After{' '}
                  <Box inline textColor="orange">
                    Sol
                  </Box>{' '}
                  has passed, you will gain a rank to spend on a new power and
                  level up your already existing ones.
                </>
              )}
            </Box>
          )}
          {tab === 6 && (
            // Lair
            <Box>
              <Box fontSize="20px" textColor="green" bold>
                Your Lair
              </Box>
              <br />
              Every vampire needs a crypt. Whether it be in maintenance or the{' '}
              {"captain's"} bathroom, this is where you will vassalize the crew
              and recieve your vampiric gifts.
              <br /> <br />
              To claim a lair you should first locate a hidden area that nobody
              will <b>ever</b> walk into. After securing your chosen location,
              bring a coffin there and rest in it to claim the area.
              <br /> <br />
              Coffins can either be made in the{' '}
              <Box inline textColor="blue">
                Crafting Menu
              </Box>{' '}
              in the{' '}
              <Box inline textColor="blue">
                Furniture
              </Box>{' '}
              category, or they can be found across the station. Most stations
              have coffins in the Chapel!
              <br /> <br />
              After you have claimed your lair, you can anchor vampiric
              structures down such as the{' '}
              <Box inline textColor="purple">
                Persuasion Rack
              </Box>{' '}
              and{' '}
              <Box inline textColor="darkred">
                Blood Throne
              </Box>
              .
            </Box>
          )}
          {tab === 7 && (
            // Structures
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                Structures
              </Box>
              <br />
              <Box textColor="purple">Persuasion Rack</Box>The Persuasion Rack
              is used to vassalize crewmembers into your loyal thralls.
              <br /> <br />
              To use it, first secure it in your{' '}
              <Box inline textColor="green">
                Lair
              </Box>{' '}
              and then capture and restrain a subject. After restraining them,
              drag them onto the rack and repeatedly torture them by clicking on
              the rack.
              <br /> <br />
              <b>
                Torturing someone with a sharp tool will make the process
                faster!
              </b>
              <br /> <br />
              If your target is{' '}
              <Box inline textColor="#555555">
                Mindshielded
              </Box>{' '}
              or otherwise disloyal to Nanotrasen they{' '}
              <b>can only be converted if their mind is weak enough.</b>
              <br />
              Crew that serve eldritch gods cannot be converted.
              <br /> <br />
              <Box textColor="yellow">Candelabrum</Box>A Candelabrum is a
              vampiric candle that will drain the sanity of any mortals viewing
              it.
              <br /> <br />
              <Box textColor="darkred">Blood Throne</Box>Sitting on this throne
              will allow you to commune with all of your vassals by{' '}
              <b>speaking out loud.</b> They cannot respond to you.
            </Box>
          )}
          {tab === 8 && (
            // Vassals
            <Box>
              <Box fontSize="20px" textColor="purple" bold>
                Vassals
              </Box>
              <br />
              Crewmembers can be vassalized by building a{' '}
              <Box inline textColor="purple">
                Persuasion Rack.
              </Box>
              <br /> <br />
              After securing this in your Lair you can use it by first capturing
              a subject and restraining them. After this, drag them onto the
              rack and torture them by clicking on the rack.
              <br /> <br />
              <b>
                Torturing someone with a sharp tool will make the process
                faster!
              </b>
              <br /> <br />
              If your target is{' '}
              <Box inline textColor="blue">
                Mindshielded
              </Box>{' '}
              or otherwise disloyal to Nanotrasen they{' '}
              <b>can only be converted if their mind is weak enough</b>. Crew
              that serve eldritch gods cannot be converted.
              <br /> <br />
              After sucessfully torturing your latest vassal, they can only be
              deconverted by use of{' '}
              <Box inline textColor="blue">
                Mindshield.
              </Box>{' '}
              You can however promote <b>one</b> vassal into your{' '}
              <Box inline textColor="gold">
                Favorite Vassal
              </Box>
              , which will gain powers unique to the Clan that you have chosen
              and will be immune to{' '}
              <Box inline textColor="blue">
                Mindshields.
              </Box>{' '}
              <br /> <br />
              <b>NOTE:</b> You can only vasaslize a certain amount of people
              based on how many crewmembers there are! The <i>Tremere</i> clan
              has this limit increased.
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
            To enter a clan you must first claim a lair by sleeping in a coffin.
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
            <Box fontSize="16px">{ClanInfo.description}</Box>
          </Stack.Item>
        </Stack>
      ))}
    </Section>
  );
};
