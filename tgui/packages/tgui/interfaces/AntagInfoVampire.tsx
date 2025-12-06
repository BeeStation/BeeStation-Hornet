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
    <Window width={700} height={700} theme="spooky">
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
      <Stack.Item grow maxHeight="220px">
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

  // small vertical padding for each tab; tweak values as desired
  const guideTabStyle = { paddingTop: '10px', paddingBottom: '10px' } as const;

  return (
    <Section title="Guide">
      <Stack>
        <Stack.Item>
          <Tabs vertical>
            <Tabs.Tab
              icon="list"
              selected={tab === 1}
              onClick={() => setTab(1)}
              style={guideTabStyle}
            >
              The Basics
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 2}
              onClick={() => setTab(2)}
              style={guideTabStyle}
            >
              The Masquerade
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 3}
              onClick={() => setTab(3)}
              style={guideTabStyle}
            >
              Humanity
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 4}
              onClick={() => setTab(4)}
              style={guideTabStyle}
            >
              Princes & Society
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 5}
              onClick={() => setTab(5)}
              style={guideTabStyle}
            >
              Sol & Levelling
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 6}
              onClick={() => setTab(6)}
              style={guideTabStyle}
            >
              Vitae
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 7}
              onClick={() => setTab(7)}
              style={guideTabStyle}
            >
              Combat
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 8}
              onClick={() => setTab(8)}
              style={guideTabStyle}
            >
              Your Lair
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 9}
              onClick={() => setTab(9)}
              style={guideTabStyle}
            >
              Structures
            </Tabs.Tab>
            <Tabs.Tab
              icon="list"
              selected={tab === 10}
              onClick={() => setTab(10)}
              style={guideTabStyle}
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
                {' '}
                So you&apos;re a big bad vampire. Congrats.{' '}
              </Box>{' '}
              <Box fontSize="30px" textColor="red" bold>
                {' '}
                Now keep it to yourself.{' '}
              </Box>{' '}
              <Box align="right" fontSize="11px" textColor="grey" bold>
                {' '}
                - &apos;Smiling&apos; Jack, Los Angeles, circa 2001-2008.{' '}
              </Box>{' '}
              <br />
              <br />
              Vampires survive because mortals think we&apos;re myths.
              That&apos;s the <b>Masquerade</b>. It&apos;s the wolf not wanting
              the sheep to know he&apos;s there. Except the sheep have guns,
              lots of them.
              <br />
              <Box inline fontSize="16px" textColor="red">
                <b>
                  You <i>must</i> stay hidden.
                </b>
              </Box>
              <br />
              <br />
              <Box fontSize="20px" textColor="gold" bold>
                Blending In
              </Box>
              You&apos;re dead. That means no breath, food, sleep, or heartbeat.{' '}
              <b>That makes you stand out.</b> Avoid doctors, scans, and
              anything that might expose you.
              <br />
              More dangerous still: the <b>Curator</b>. They know vampires exist
              and can expose you instantly. Stay far away.
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                * Tip: You may have insane and awesome powers, but, that
                doesn&apos;t mean you have to use them.{' '}
                <b>
                  Wise kindred pick and choose when they rip open a security
                  officer with their bare hands, or just use a normal gun.
                </b>
              </Box>
              <br />
              <Box fontSize="20px" textColor="green" bold>
                HUD & First Steps
              </Box>
              See those icons on the left? They&apos;re your HUD. Click them,
              learn what they show.
              <br />
              <br />
              Your smartest move right now is to find another kindred. They
              might even point you toward the local prince.
              <br />
              <br />
              <Box fontSize="20px" textColor="magenta" bold>
                The #1 Tip on how to stay alive
              </Box>
              Keep your vitae above 300. There is so much that can go wrong in a
              panic, so much chaos that can unfold. A starving vampire is a
              careless vampire.
              <br />
              <br />
              <Box fontSize="15px" textColor="grey">
                All ways a kindred can die start with insufficient vitae. It
                sneaks up on you, and suddenly you&apos;re running around
                panicking, making mistakes. Be smart, be careful.
              </Box>
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
              <Box inline textColor="gold">
                The Masquerade
              </Box>{' '}
              is an organized disinformation campaign heavily enforced by
              Kindred society (mainly the{' '}
              <Box inline textColor="pink">
                Camarilla
              </Box>
              ), meant to convince humans that vampires and various other
              supernatural creatures do not exist.
              <br /> <br />
              If a mortal witnesses you doing anything out of the ordinary at
              all, you will recieve a{' '}
              <Box inline textColor="red">
                Masquerade Infraction.
              </Box>
              <br /> <br />
              You will be allowed <b>three</b>{' '}
              <Box inline textColor="red">
                Masquerade Infractions
              </Box>{' '}
              before you are exiled from the Kindred and{' '}
              <Box inline fontSize="13px" textColor="red" bold>
                <b>ALL</b>
              </Box>{' '}
              vampires turn against you.
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
              <br /> <br /> If your humanity is above 7, you will receive the
              &apos;Masquerade&apos; ability, a power to help you blend in to a
              degree that is even able to fool health analyzers. You will
              functionally restore most mortal bodily processes. <br />
              <b>This means you will not heal as usual.</b>
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                * Tip: You may want to limit the blood you take from crew. Too
                many people checking into the medbay with bloodloss is just as
                obvious as a bloodless corpse lying in the halls.
              </Box>
              <br /> <br />
              <Box fontSize="20px" textColor="red" bold>
                I broke the masquerade, what now?
              </Box>{' '}
              - Everyone will hunt you. Vampires likely more than mortals.
              <br /> - Any vassals you have are now up for grabs for any other
              vampires.
              <br /> - Other vampires can now feed on you. Expect final death if
              they do so.
              <br /> -{' '}
              <b>
                If a vampire drains another to dryness, they will absorb their
                powers.
              </b>
              <br /> - It is too late to beg for mercy.
            </Box>
          )}
          {tab === 3 && (
            // Humanity
            <Box>
              <Box fontSize="20px" textColor="gold" bold>
                Humanity.
              </Box>
              <Box fontSize="15px" textColor="gold" bold>
                Are we human? Or are we dancer?
              </Box>
              <br />
              Since most Kindred were a human before their Embrace, their most
              natural response in resisting the Beast&apos;s feral, predatory
              nature is to cling to their{' '}
              <Box inline textColor="blue">
                humanity
              </Box>
              .
              <br />
              <br />A Kindred&apos;s{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              has a direct effect on the strength of the vampiric curse; those
              who lose ground to the Beast and lose their{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              find it more difficult to interact with mortals, to be active
              during daylight hours, and to awaken from long periods of torpor.
              <br />
              <br />
              <Box inline textColor="gold">
                For more information on your humanity in specifics, click the
                humanity counter on the left side of your screen.
              </Box>
              <br />
              <br /> In this day and age, you may find it strange to call it{' '}
              <Box inline textColor="blue">
                &apos;Humanity&apos;
              </Box>
              , given that a fair few kindred aren&apos;t human at all. The
              explanation for this is as simple as it is common. Like so many
              other things in vampire society, it is tradition.
              <br />
              <br />
              Turns out traditions are slow to adapt or change, if the people
              holding on to them are centuries old.
            </Box>
          )}
          {tab === 4 && (
            // Society.
            <Box>
              <Box fontSize="20px" textColor="darkred" bold>
                Princes & Scourges
              </Box>
              <br />A{' '}
              <Box inline textColor="red">
                Prince
              </Box>{' '}
              is an elder vampire entrusted by the camarilla and recognized by
              the other princes. They rule their territories with iron fists,
              keeping track of every kindred present.
              <br />
              <br />
              They of course do not do so alone. Many a prince may employ the
              services of a{' '}
              <Box inline textColor="red">
                Scourge
              </Box>
              , a sort of enforcer. Loyal to them and only them. Many scourges
              are chosen from clans such as the Tremere, but some rare princes
              were known to employ even Brujah scourges.
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                * Important:
              </Box>
              <Box fontSize="15px" textColor="blue">
                Princes have higher expectations placed upon them than normal
                vampires. Please be aware that they are supposed to be the
                &apos;Responsible&apos; ones in most situations.
                <br />
                <br />
                <b>
                  You must protect the masquerade viciously. Do not hesitate to
                  deliver final death to other kindred should they test their
                  limits.
                </b>
              </Box>
              <br />
              <br />
              <Box fontSize="20px" textColor="purple" bold>
                The Camarilla
              </Box>
              <br />
              The{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              is a decentralized form of government, the most organised of the
              vampiric sects, an elite club that favours tradition and control
              of the mortal populace from behind the scenes. Most vampire clans
              these days are part of them.{' '}
              <Box inline textColor="orange">
                Notably, the Brujah insist on remaining independent.
              </Box>{' '}
              <br />
              <br />
              Every city or station, every colony or outpost. If it has a
              kindred presence, the camarilla knows. And there will be a{' '}
              <Box inline textColor="red">
                Prince
              </Box>{' '}
              to oversee it.
              <br />
              <br />
              The{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              are the chief enforcers of the{' '}
              <Box inline textColor="gold">
                Masquerade
              </Box>{' '}
              .
            </Box>
          )}
          {tab === 5 && (
            // Sol
            <Box>
              <Box fontSize="40px" textColor="orange" bold>
                Sol.
              </Box>
              <br />
              First things first:{' '}
              <Box inline textColor="gold">
                &apos;Sol&apos;
              </Box>{' '}
              does not refer to the sun that you, the player, knows.
              <br />
              <br />
              Vampires actually do really well in space. You are just lucky
              enough to get stuck very near to a very temperamental star. Yay!
              <br />
              <br />
              Here is what you need to know about the periodic solar storms
              we&apos;ve come to calling{' '}
              <Box inline textColor="gold">
                &apos;Sol&apos;
              </Box>
              :<br />
              <br /> -{' '}
              <b>
                You can find out more by clicking on the hud icon at the left
                side of your screen.
              </b>
              <br /> - You cannot ever die to sol as long as you protect
              yourself. In lockers, Maintenance, or Coffins, vitae will never
              drain to 0.
              <br /> -{' '}
              <Box inline textColor="red">
                Do not be caught unprotected. You will burn up and turn to dust.
              </Box>
              <br /> - Your{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              is able to grant you partial resistance to it.
              <br />
              <br />
              <Box fontSize="15px" textColor="red">
                Hindered Healing
              </Box>
              You lose the ability to passively heal unless inside a{' '}
              <Box inline textColor="blue">
                coffin
              </Box>{' '}
              and take 50% more damage as a whole.
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                Impaired Powers
              </Box>
              All powers take twice their usual cooldown, most powers take more{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              to use and maintain, and other powers are completely blocked.
              <br />
              <br />
              After{' '}
              <Box inline textColor="orange">
                Sol
              </Box>{' '}
              has passed, you will gain a rank to spend on upgrading your
              disciplines.
              <br />
              <br />
              <Box fontSize="20px" textColor="darkred" bold>
                Growing in Power
              </Box>
              Click on your blood meter. You will notice a progress tracker.
              <br />
              At the end of each{' '}
              <Box inline textColor="yellow">
                Sol
              </Box>
              , provided you have drank he amount of vitae in your goal, you
              gain a Rank. <br />
              Ranking up boosts strength, health, feeding rate, and blood
              capacity.
              <br />
              You also earn discipline points. These powers aren&apos;t
              optional. They&apos;re how you survive.
            </Box>
          )}
          {tab === 6 && (
            // Vitae
            <Box>
              <Box fontSize="20px" textColor="red" bold>
                Vitae Drain
              </Box>
              <br />
              As an undead, you constantly feel the hunger of the{' '}
              <Box inline textColor="orange">
                Beast
              </Box>
              . Feeding is not a luxury. <b>It is a necessity.</b> As your blood
              reaches zero, you will slowly feel the side-effects, such as
              blurry vision, and impaired healing.
              <br />
              <br />
              The amount of Blood a vampire can absorb into his body, as well as
              the power he can drain from it in short notice, is determined by
              the vampire&apos;s rank.
              <br />
              <br />
              You can gain{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              from any of four ways:
              <br /> - <b>Your fellow crewmembers.</b>
              <br /> - Monkeys
              <br /> - Mice
              <br /> - Bloodbags
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                * Tip: Do not be afraid to feed from crew. It is both routine
                and required. You cannot survive on snacks in the long run.
              </Box>
              <br />
              <Box fontSize="20px" textColor="orange" bold>
                Frenzy
              </Box>
              If you ever deplete all of your vitae, you will enter a{' '}
              <Box inline textColor="orange">
                frenzy.
              </Box>{' '}
              In this state, diplomacy goes out the window. You will revert to a
              feral beast, likely assaulting and draining the nearest mortal you
              can see.
              <br /> <br />
              In{' '}
              <Box inline textColor="orange">
                frenzy
              </Box>
              , you are able to instantly grab people aggressively. After
              consuming enough blood, you will return to your senses.
              <br /> <br />
              <Box fontSize="20px" textColor="blue">
                Powers
              </Box>
              All powers cost{' '}
              <Box inline textColor="red">
                vitae.
              </Box>{' '}
              Some powers can be toggled and drain{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              while active. Others simply remove their cost in{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              immediately on use.
              <br />
              <br />
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
          {tab === 7 && (
            // Combat
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                Combat as an immortal freak:
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
                vitae
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
              <Box textColor="orange">Burn Damage</Box>Even with the fortitude
              discipline, vampires are inherently weak to the purifying effect
              of fire. Avoid lasers and fire at all costs, you are barely more
              than any mortal in the eyes of an officer with a laser weapon.
              <br /> <br />
              <Box textColor="gold">Sol</Box>Every <b>10 minutes</b> Sol will
              bathe the station in sunlight, severely hindering you unless in a
              coffin.
              <br /> <br />
              <Box textColor="pink">The Masquerade</Box>All vampires swear an
              oath to maintain their secrecy and vampirism. If you break this
              oath, other vampires will turn against you.
              <br /> <br />
            </Box>
          )}
          {tab === 8 && (
            // Lairs
            <Box>
              <Box fontSize="20px" textColor="green" bold>
                Your Lair
              </Box>
              <br />
              Some vampires may want to claim a Lair. Whether it be in
              maintenance or the captain&apos;s bathroom, this is where you will
              vassalize the crew and retreat to for healing.
              <br /> <br />
              To claim a Lair you should first locate a hidden area that nobody
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
              After you have claimed your Lair, you can anchor vampiric
              structures down such as the{' '}
              <Box inline textColor="purple">
                Vassalization Rack
              </Box>{' '}
              and{' '}
              <Box inline textColor="darkred">
                Blood Throne
              </Box>
              .
              <br />
              <br />
              <Box fontSize="15px" textColor="blue">
                * Tip: Not every vampire needs a lair. The main way vampires get
                found out these days, is through their lair.
                <br />
                <b>
                  If you build one, just building it in maintenance is not
                  enough. It has to be in a place no one will look.
                </b>
              </Box>
            </Box>
          )}
          {tab === 9 && (
            // Structures
            <Box>
              <Box fontSize="20px" textColor="blue" bold>
                Structures
              </Box>
              <br />
              <Box fontSize="15px" textColor="blue">
                * You can build all vampire structures using the
                &apos;Vampire&apos; crafting tab in your crafting menu.
              </Box>
              <br />
              <Box textColor="purple">Vassalization Rack</Box>The Vassalization
              Rack is used to vassalize crewmembers into your loyal thralls.
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
              will allow you to commune with all other kindred by{' '}
              <b>speaking out loud.</b> They cannot respond to you unless they
              have their own throne.
            </Box>
          )}
          {tab === 10 && (
            // Vassals
            <Box>
              <Box fontSize="20px" textColor="purple" bold>
                Vassals
              </Box>
              <br />
              Crewmembers can be vassalized by building a{' '}
              <Box inline textColor="purple">
                Vassalization Rack.
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
              </Box>
              <br /> <br />
              <b>NOTE:</b> You can only vasaslize a certain amount of people
              based on how many crewmembers there are!
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
