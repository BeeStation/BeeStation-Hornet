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
  // Set default to 2 so Basics (now in the middle) opens by default
  const [tab, setTab] = useLocalState('tab', 2);

  // Styles for the top-level tabs:
  const topTabsStyle = {
    display: 'flex',
    width: '100%',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;
  const topTabStyle = {
    flex: 1,
    fontSize: '25px',
    padding: '10px 12px',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    textAlign: 'center',
    fontWeight: 900,
    letterSpacing: '0.5px',
    textShadow: '0 1px 0 rgba(0,0,0,0.6)',
    fontFamily:
      '"Cinzel Decorative", "Uncial Antiqua", "Old English Text MT", serif',
  } as const;

  return (
    <Window width={700} height={750} theme="spooky">
      <Window.Content>
        <Box align="center" style={{ width: '100%' }}>
          <Tabs style={topTabsStyle}>
            {/* Guide on the left */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === 1}
              onClick={() => setTab(1)}
            >
              General Guide
            </Tabs.Tab>

            {/* Basics in the middle (slightly larger/bold for emphasis) */}
            <Tabs.Tab
              style={{ ...topTabStyle, fontSize: '30px', fontWeight: 900 }}
              selected={tab === 2}
              onClick={() => setTab(2)}
            >
              Basics
            </Tabs.Tab>

            {/* Powers on the right */}
            <Tabs.Tab
              style={topTabStyle}
              selected={tab === 3}
              onClick={() => setTab(3)}
            >
              Powers
            </Tabs.Tab>
          </Tabs>
        </Box>

        {/* Re-map which component shows for each tab index to match the new ordering */}
        {tab === 1 && <VampireGuide />}
        {tab === 2 && <VampireIntroduction />}
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
        <Stack.Item grow basis={0} style={{ overflow: 'auto' }}>
          {tab === 1 && (
            // The Basics
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                So you&apos;re a big bad vampire. Congrats.
              </Box>
              <Box fontSize="26px" textColor="red" bold>
                Now keep it to yourself.
              </Box>
              <Box align="right" fontSize="10px" textColor="grey">
                - &apos;Smiling&apos; Jack, Los Angeles, circa 2001-2008.
              </Box>
              <br />
              Vampires survive because mortals think they&apos;re myths.
              That&apos;s the{' '}
              <Box inline textColor="gold">
                Masquerade
              </Box>
              . The wolf doesn&apos;t want the sheep to know he&apos;s there.
              Except these sheep have guns.
              <Box inline fontSize="14px" textColor="red" bold>
                {' '}
                You <i>must</i> stay hidden.
              </Box>
              <br />
              <br />
              <Box fontSize="16px" textColor="gold" bold>
                Blending In
              </Box>
              You&apos;re dead: no breath, heartbeat, or need for food. That
              makes you stand out. Avoid doctors, health scans, and especially
              the{' '}
              <Box inline textColor="pink">
                Curator
              </Box>
              . They know vampires exist and can expose you.
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Tip:</b> You have incredible powers, but using them draws
                attention. Wise kindred blend in by acting like mortals. Use a
                gun instead of claws. Walk instead of leaping across rooms.
                Reserve your powers for when you truly need them.
              </Box>
              <br />
              <Box fontSize="16px" textColor="green" bold>
                First Steps
              </Box>
              Take a moment to look at your screen. See those icons on the left?
              That&apos;s your vampire HUD. Each icon gives you important
              information, so click through them and learn what they show.
              <br />
              <br />
              Your next priority should be finding another kindred. They can
              help you learn the ropes, and they might point you toward the
              local{' '}
              <Box inline textColor="red">
                Prince
              </Box>
              .
              <br />
              <Box
                mt={1}
                style={{
                  border: '2px solid #ff4444',
                  borderRadius: '6px',
                  padding: '8px',
                  backgroundColor: 'rgba(255, 0, 0, 0.1)',
                }}
              >
                <Box fontSize="15px" textColor="red" bold textAlign="center">
                  #1 RULE OF SURVIVAL
                </Box>
                <Box fontSize="18px" textColor="gold" bold textAlign="center">
                  Keep vitae above 300.
                </Box>
                <Box fontSize="12px" textAlign="center">
                  A starving vampire is a dead vampire. Panic leads to mistakes.
                </Box>
                <Box fontSize="11px" textColor="grey" textAlign="center">
                  Feed often. Feed smart. Stay alive.
                </Box>
              </Box>
            </Box>
          )}
          {tab === 2 && (
            // The Masquerade
            <Box>
              <Box fontSize="18px" textColor="gold" bold>
                The Masquerade
              </Box>
              <Box fontSize="13px" textColor="gold">
                How to keep from getting us all killed.
              </Box>
              <br />
              The{' '}
              <Box inline textColor="gold">
                Masquerade
              </Box>{' '}
              is an organized disinformation campaign enforced by{' '}
              <Box inline textColor="purple">
                Kindred
              </Box>{' '}
              society (mainly the{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>
              ) to convince humans that vampires do not exist.
              <br />
              <br />
              If a mortal witnesses anything suspicious, you receive a{' '}
              <Box inline textColor="red">
                Masquerade Infraction
              </Box>
              . After <b>three</b>, you are exiled and{' '}
              <Box inline textColor="red" bold>
                ALL
              </Box>{' '}
              vampires turn against you.
              <br />
              <br />
              The{' '}
              <Box inline textColor="pink">
                Curator
              </Box>{' '}
              possesses the{' '}
              <Box inline textColor="blue">
                Archive of the Kindred
              </Box>
              , which can instantly expose you. However, if your{' '}
              <Box inline textColor="gold">
                Masquerade Ability
              </Box>{' '}
              is active, even this ancient tome cannot see through your
              disguise.
              <br />
              <br />
              At{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              above 7, you gain the{' '}
              <Box inline textColor="gold">
                Masquerade Ability
              </Box>
              , which fools health analyzers and the{' '}
              <Box inline textColor="pink">
                Curator
              </Box>
              . <b>However, you will not heal normally while it is active.</b>
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Tip:</b> Too many bloodloss patients in medbay is just as
                suspicious as a bloodless corpse in the halls.
              </Box>
              <br />
              <Box fontSize="16px" textColor="red" bold>
                I broke the Masquerade. Now what?
              </Box>
              <Box fontSize="13px">
                • Everyone hunts you, vampires more than mortals
                <br />
                • Your vassals are up for grabs
                <br />
                • Other vampires can feed on you
                <br />• <b>Draining another vampire grants you their powers</b>
                <br />• It is too late for mercy
              </Box>
            </Box>
          )}
          {tab === 3 && (
            // Humanity
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Humanity
              </Box>
              <Box fontSize="13px" textColor="blue">
                Are we human? Or are we dancer?
              </Box>
              <br />
              Most{' '}
              <Box inline textColor="purple">
                Kindred
              </Box>{' '}
              were human before their Embrace. Clinging to{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              is how they resist the{' '}
              <Box inline textColor="orange">
                Beast&apos;s
              </Box>{' '}
              feral nature.
              <br />
              <br />
              Your{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              directly affects the vampiric curse. Lower{' '}
              <Box inline textColor="blue">
                humanity
              </Box>{' '}
              means:
              <br />
              <Box fontSize="13px" ml={1}>
                • Harder to interact with mortals
                <br />
                • Difficult to stay active during daylight
                <br />• Longer{' '}
                <Box inline textColor="orange">
                  torpor
                </Box>{' '}
                recovery
              </Box>
              <br />
              <Box
                fontSize="13px"
                textColor="gold"
                style={{
                  borderLeft: '2px solid #ffd700',
                  paddingLeft: '8px',
                }}
              >
                Click the humanity counter on your HUD for detailed information.
              </Box>
              <br />
              Why call it{' '}
              <Box inline textColor="blue">
                Humanity
              </Box>{' '}
              when not all{' '}
              <Box inline textColor="purple">
                kindred
              </Box>{' '}
              were human? Simple: tradition. Centuries-old vampires are slow to
              change their ways.
            </Box>
          )}
          {tab === 4 && (
            // Society
            <Box>
              <Box fontSize="18px" textColor="darkred" bold>
                Princes & Scourges
              </Box>
              <br />A{' '}
              <Box inline textColor="red">
                Prince
              </Box>{' '}
              is an elder vampire entrusted by the{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              to rule a territory. They keep track of every{' '}
              <Box inline textColor="purple">
                kindred
              </Box>{' '}
              present and enforce the{' '}
              <Box inline textColor="gold">
                Masquerade
              </Box>{' '}
              with an iron fist.
              <br />
              <br />
              Of course, they do not work alone. Many{' '}
              <Box inline textColor="red">
                Princes
              </Box>{' '}
              employ a{' '}
              <Box inline textColor="red">
                Scourge
              </Box>
              , a personal enforcer loyal only to them. Scourges are often
              chosen from clans like the Tremere, though some rare{' '}
              <Box inline textColor="red">
                Princes
              </Box>{' '}
              have been known to employ even Brujah.
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Important:</b> Princes have higher expectations placed upon
                them. They must protect the Masquerade at all costs and deliver
                final death to misbehaving kindred without hesitation.
              </Box>
              <br />
              <Box fontSize="18px" textColor="purple" bold>
                The Camarilla
              </Box>
              <br />
              The{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              is the most organized vampiric sect: an elite club that favors
              tradition and covert control of mortals from behind the scenes.
              Most vampire clans are part of them, though the{' '}
              <Box inline textColor="orange">
                Brujah notably insist on remaining independent
              </Box>
              .
              <br />
              <br />
              Every city, station, colony, or outpost with a{' '}
              <Box inline textColor="purple">
                kindred
              </Box>{' '}
              presence has a{' '}
              <Box inline textColor="red">
                Prince
              </Box>{' '}
              assigned by the{' '}
              <Box inline textColor="purple">
                Camarilla
              </Box>{' '}
              to oversee it. They are the chief enforcers of the{' '}
              <Box inline textColor="gold">
                Masquerade
              </Box>
              .
            </Box>
          )}
          {tab === 5 && (
            // Sol
            <Box>
              <Box fontSize="32px" textColor="orange" bold>
                Sol
              </Box>
              <Box inline textColor="yellow">
                Sol
              </Box>{' '}
              refers to the nearby temperamental star, not Earth&apos;s sun.
              Vampires do well in space. You are just unlucky enough to be near
              this one.
              <br />
              <br />
              <Box fontSize="14px" bold>
                Key Facts
              </Box>
              <Box fontSize="13px">
                • Click the HUD icon for more detailed information
                <br />
                • You cannot die to Sol if you are protected by lockers,
                maintenance tunnels, or coffins
                <br />
                • If you are caught unprotected, you will burn to dust
                <br />• Higher humanity grants partial resistance to Sol&apos;s
                effects
              </Box>
              <br />
              <Box fontSize="14px" bold textColor="red">
                During Sol
              </Box>
              <Box fontSize="13px">
                • You cannot passively heal; only coffins can restore you
                <br />
                • You take 50% more damage from all sources
                <br />• Your powers have doubled cooldowns, increased vitae
                costs, and some are blocked entirely
              </Box>
              <br />
              <Box fontSize="16px" textColor="darkred" bold>
                Growing in Power
              </Box>
              As a vampire, you grow stronger over time by meeting your feeding
              requirements. Click your blood meter on the HUD to see your
              current progress toward the next rank.
              <br />
              <br />
              After each Sol cycle, if you have consumed enough vitae to meet
              your goal, you will gain a Rank. Each rank provides significant
              benefits:
              <Box fontSize="13px" ml={1}>
                • Increased physical strength
                <br />
                • Greater health pool
                <br />
                • Faster feeding rate
                <br />
                • Higher blood capacity
                <br />• Additional discipline points to unlock new powers
              </Box>
            </Box>
          )}
          {tab === 6 && (
            // Vitae
            <Box>
              <Box fontSize="18px" textColor="red" bold>
                Vitae
              </Box>
              <br />
              <Box inline textColor="red">
                Vitae
              </Box>{' '}
              is the lifeblood that sustains every vampire. The{' '}
              <Box inline textColor="orange">
                Beast
              </Box>{' '}
              within you demands constant feeding, and ignoring this need is not
              an option. When your blood reserves reach zero, you will
              experience blurred vision, impaired healing, and far worse
              consequences.
              <br />
              <br />
              Your current rank determines how much{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              you can store and utilize at any given time.
              <br />
              <br />
              <Box bold>
                Sources of{' '}
                <Box inline textColor="red">
                  vitae
                </Box>
                :
              </Box>
              <Box fontSize="13px">
                • Crewmembers
                <br />
                • Monkeys
                <br />
                • Mice
                <br />• Bloodbags
              </Box>
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Tip:</b> Feed from crew regularly. Mice and monkeys will not
                sustain you in the long run.
              </Box>
              <br />
              <Box fontSize="16px" textColor="orange" bold>
                Frenzy
              </Box>
              When your{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              is completely depleted, you lose control and enter a state known
              as{' '}
              <Box inline textColor="orange">
                frenzy
              </Box>
              . In this feral state, the{' '}
              <Box inline textColor="orange">
                Beast
              </Box>{' '}
              takes over and compels you to attack the nearest mortal without
              hesitation.
              <br />
              <br />
              While in{' '}
              <Box inline textColor="orange">
                frenzy
              </Box>
              , you gain the ability to grab victims instantly, making you
              extremely dangerous but also highly conspicuous. The only way to
              regain control of yourself is to feed until you have enough{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              to suppress the{' '}
              <Box inline textColor="orange">
                Beast
              </Box>
              .
              <br />
              <br />
              <Box fontSize="16px" textColor="blue" bold>
                Powers & Vitae
              </Box>
              All of your vampiric powers require{' '}
              <Box inline textColor="red">
                vitae
              </Box>{' '}
              to use. Some abilities drain blood continuously while they remain
              active, while others have an upfront cost when activated. Check
              the Powers tab for specific costs and details on each ability.
            </Box>
          )}
          {tab === 7 && (
            // Combat
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Combat
              </Box>
              <br />
              As a vampire, you have significant advantages in combat, but also
              critical weaknesses that can be exploited.
              <br />
              <br />
              <Box fontSize="15px" textColor="green" bold>
                Strengths
              </Box>
              <Box fontSize="13px">
                <b>Enhanced Senses:</b> Night vision and thermal vision let you
                track prey in complete darkness.
                <br />
                <br />
                <b>Undead Physiology:</b> No need to breathe, sleep, or eat. You
                are immune to disease. Fatal wounds put you into{' '}
                <Box inline textColor="orange">
                  Torpor
                </Box>{' '}
                instead of killing you. You will rise again if you have{' '}
                <Box inline textColor="red">
                  vitae
                </Box>{' '}
                and are not staked.
                <br />
                <br />
                <b>Resilience:</b> Immune to cold, radiation, and toxins.
                Critical injuries do not knock you down.
                <br />
                <br />
                <b>Supernatural Strength:</b> Your fists deal devastating
                damage, scaling with your rank.
              </Box>
              <br />
              <Box fontSize="15px" textColor="red" bold>
                Weaknesses
              </Box>
              <Box fontSize="13px">
                <b>Stakes:</b> Paralyze you, disable powers, halt healing, and
                prevent revival from{' '}
                <Box inline textColor="orange">
                  Torpor
                </Box>
                .
                <br />
                <br />
                <b>Fire and Lasers:</b> Deal devastating damage. Fortitude
                offers minimal protection.
                <br />
                <br />
                <b>Sol:</b> Every ten minutes, sunlight cripples you unless
                protected by a coffin or similar shelter.
                <br />
                <br />
                <b>The Masquerade:</b> Break it and every vampire turns against
                you. You will be hunted by kindred and mortals alike.
              </Box>
            </Box>
          )}
          {tab === 8 && (
            // Lairs
            <Box>
              <Box fontSize="18px" textColor="green" bold>
                Your Lair
              </Box>
              <br />A{' '}
              <Box inline textColor="green">
                lair
              </Box>{' '}
              is a location you have claimed as your own, where you can rest in
              your coffin and perform certain vampiric rituals. Some vampires
              find them useful. Many more have been caught because of them.
              <br />
              <br />
              <Box bold>
                Do You Need a{' '}
                <Box inline textColor="green">
                  Lair
                </Box>
                ?
              </Box>
              <Box fontSize="13px">
                Honestly? Probably not. A{' '}
                <Box inline textColor="green">
                  lair
                </Box>{' '}
                is only necessary if you intend to create{' '}
                <Box inline textColor="purple">
                  vassals
                </Box>{' '}
                or use certain structures. If you just need somewhere to hide
                during{' '}
                <Box inline textColor="yellow">
                  Sol
                </Box>
                , any dark corner with a locker will do. The more infrastructure
                you build, the more evidence you leave behind.
              </Box>
              <br />
              <Box bold>
                Claiming a{' '}
                <Box inline textColor="green">
                  Lair
                </Box>
              </Box>
              <Box fontSize="13px">
                If you still want one: acquire a coffin from the Chapel or craft
                one via the Furniture category. Find somewhere{' '}
                <i>truly hidden</i>, place the coffin, and rest inside to claim
                the area. Once claimed, you can anchor vampiric structures like
                the{' '}
                <Box inline textColor="purple">
                  Vassalization Rack
                </Box>{' '}
                or{' '}
                <Box inline textColor="darkred">
                  Blood Throne
                </Box>
                .
              </Box>
              <br />
              <Box
                mt={1}
                fontSize="13px"
                textColor="blue"
                style={{
                  borderLeft: '2px solid #4444ff',
                  paddingLeft: '8px',
                }}
              >
                <b>Warning:</b> Maintenance is the first place people look. If
                someone finds your lair, they find everything: your coffin, your
                structures, your vassals, and you.
              </Box>
            </Box>
          )}
          {tab === 9 && (
            // Structures
            <Box>
              <Box fontSize="18px" textColor="blue" bold>
                Structures
              </Box>
              <Box fontSize="13px" textColor="blue">
                These can be built via the Vampire crafting tab.
              </Box>
              <br />
              <Box textColor="purple" bold>
                Vassalization Rack
              </Box>
              <Box fontSize="13px">
                The vassalization rack is your tool for converting captured
                crewmembers into loyal{' '}
                <Box inline textColor="purple">
                  vassals
                </Box>{' '}
                who will serve your every command.
                <br />
                <br />
                <b>Usage:</b> Secure the rack in your{' '}
                <Box inline textColor="green">
                  lair
                </Box>{' '}
                → restrain your target → drag them onto the rack → click the
                rack to begin the torture process.
                <br />
                <br />
                You can speed up the conversion significantly by using{' '}
                <Box inline textColor="red">
                  sharp tools
                </Box>{' '}
                on the victim while they are restrained.
              </Box>
              <br />
              <Box fontSize="13px">
                Crewmembers with{' '}
                <Box inline textColor="blue">
                  mindshields
                </Box>{' '}
                or strong loyalties require their mental defenses to be weakened
                first.{' '}
                <Box inline textColor="purple">
                  Eldritch servants
                </Box>{' '}
                are completely immune and can never be converted.
              </Box>
              <br />
              <Box textColor="yellow" bold>
                Candelabrum
              </Box>
              <Box fontSize="13px">
                A vampiric candelabra that radiates an unsettling aura. Any
                mortal who gazes upon its{' '}
                <Box inline textColor="orange">
                  flame
                </Box>{' '}
                will find their sanity slowly draining away.
              </Box>
              <br />
              <Box textColor="darkred" bold>
                Blood Throne
              </Box>
              <Box fontSize="13px">
                When you sit upon a Blood Throne, your words are broadcast
                telepathically to all{' '}
                <Box inline textColor="purple">
                  kindred
                </Box>{' '}
                on the station. Other vampires will need their own throne if
                they wish to respond.
              </Box>
            </Box>
          )}
          {tab === 10 && (
            // Vassals
            <Box>
              <Box fontSize="18px" textColor="purple" bold>
                Vassals
              </Box>
              <br />
              <Box inline textColor="purple">
                Vassals
              </Box>{' '}
              are mortals who have been broken and bound to your will. They
              serve as your eyes, ears, and hands among the living, carrying out
              your commands while you remain hidden in the shadows.
              <br />
              <br />
              <Box bold>Creating Vassals</Box>
              <Box fontSize="13px">
                To create a vassal, you will need a{' '}
                <Box inline textColor="purple">
                  Vassalization Rack
                </Box>{' '}
                secured within your{' '}
                <Box inline textColor="green">
                  lair
                </Box>
                . Capture your target and restrain them so they cannot escape,
                then drag them onto the rack. Click the rack to begin the{' '}
                <Box inline textColor="red">
                  torture
                </Box>{' '}
                process that will break their will and bind them to you.
                <br />
                <br />
                Using{' '}
                <Box inline textColor="red">
                  sharp implements
                </Box>{' '}
                on the victim while they are restrained will accelerate the
                process considerably.
              </Box>
              <br />
              <Box bold>Limitations</Box>
              <Box fontSize="13px">
                Crewmembers protected by{' '}
                <Box inline textColor="blue">
                  mindshields
                </Box>{' '}
                or those with strong existing loyalties cannot be converted
                until their mental defenses have been weakened. Those who serve{' '}
                <Box inline textColor="purple">
                  eldritch powers
                </Box>{' '}
                are completely immune and can never be turned.
                <br />
                <br />
                Once someone has become your vassal, the only way to free them
                is through implantation of a{' '}
                <Box inline textColor="blue">
                  mindshield
                </Box>
                .
              </Box>
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
