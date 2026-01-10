import { BooleanLike } from 'common/react';
import { sanitizeText } from 'tgui/sanitize';
import { DmIcon } from 'tgui-core/components';

import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { Box, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';
import { Objective } from './common/ObjectiveSection';

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

// Custom header component for the vampire panel
const VampireHeader = () => {
  return (
    <Box className="VampireHeader">
      <Box className="VampireHeader__inner">
        <Box className="VampireHeader__portrait">
          <Box
            as="img"
            src={resolveAsset('vampire.png')}
            width="64px"
            style={{
              imageRendering: 'pixelated',
            }}
          />
        </Box>
        <Box className="VampireHeader__info">
          <Box className="VampireHeader__title">Vampire</Box>
          <Box className="VampireHeader__subtitle">
            You are a Child of the Night, a kindred cursed with dark hunger.
          </Box>
        </Box>
      </Box>
    </Box>
  );
};

// Custom objectives display
const VampireObjectives = ({ objectives }: { objectives: Objective[] }) => {
  return (
    <Box className="VampireObjectives">
      <Box className="VampireObjectives__title">Your Dark Purpose</Box>
      <Box className="VampireObjectives__list">
        {objectives.map((objective, index) => (
          <Box key={index} className="VampireObjectives__item">
            <Box className="VampireObjectives__item-number">{index + 1}.</Box>
            <Box className="VampireObjectives__item-text">
              {objective.explanation}
            </Box>
          </Box>
        ))}
      </Box>
    </Box>
  );
};

export const AntagInfoVampire = (_props) => {
  const [tab, setTab] = useLocalState('tab', 2);

  return (
    <Window width={720} height={850} theme="spooky">
      <Window.Content>
        <Box className="VampirePanel">
          <Box className="VampirePanel__navTabs">
            <Box
              className={`VampirePanel__navTab ${tab === 1 ? 'VampirePanel__navTab--selected' : ''}`}
              onClick={() => setTab(1)}
            >
              Guide
            </Box>
            <Box
              className={`VampirePanel__navTab VampirePanel__navTab--main ${tab === 2 ? 'VampirePanel__navTab--selected' : ''}`}
              onClick={() => setTab(2)}
            >
              Basics
            </Box>
            <Box
              className={`VampirePanel__navTab ${tab === 3 ? 'VampirePanel__navTab--selected' : ''}`}
              onClick={() => setTab(3)}
            >
              Powers
            </Box>
          </Box>
          <Box className="VampirePanel__content">
            {tab === 1 && <VampireGuide />}
            {tab === 2 && <VampireIntroduction />}
            {tab === 3 && <PowerSection />}
          </Box>
        </Box>
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
        <VampireHeader />
      </Stack.Item>
      <Stack.Item>
        <VampireObjectives objectives={objectives} />
      </Stack.Item>
      <Stack.Item grow>
        <ClanSection />
      </Stack.Item>
    </Stack>
  );
};

const VampireGuide = (_props) => {
  const [tab, setTab] = useLocalState('guideTab', 1);

  const guideTabs = [
    { id: 1, label: 'The Basics', icon: 'book' },
    { id: 2, label: 'The Masquerade', icon: 'mask' },
    { id: 3, label: 'Humanity', icon: 'heart' },
    { id: 4, label: 'Princes & Society', icon: 'crown' },
    { id: 5, label: 'Sol & Levelling', icon: 'sun' },
    { id: 6, label: 'Vitae', icon: 'tint' },
    { id: 7, label: 'Combat', icon: 'fist-raised' },
    { id: 8, label: 'Your Lair', icon: 'home' },
    { id: 9, label: 'Structures', icon: 'building' },
    { id: 10, label: 'Vassals', icon: 'users' },
  ];

  return (
    <Box className="VampireGuide" style={{ height: '100%' }}>
      <Box className="VampireGuide__sidebar">
        {guideTabs.map((t) => (
          <Box
            key={t.id}
            className={`VampireGuide__tab ${tab === t.id ? 'VampireGuide__tab--selected' : ''}`}
            onClick={() => setTab(t.id)}
          >
            <Icon name={t.icon} className="VampireGuide__tab-icon" />
            {t.label}
          </Box>
        ))}
      </Box>
      <Box className="VampireGuide__content">
        {tab === 1 && <GuideBasics />}
        {tab === 2 && <GuideMasquerade />}
        {tab === 3 && <GuideHumanity />}
        {tab === 4 && <GuideSociety />}
        {tab === 5 && <GuideSol />}
        {tab === 6 && <GuideVitae />}
        {tab === 7 && <GuideCombat />}
        {tab === 8 && <GuideLair />}
        {tab === 9 && <GuideStructures />}
        {tab === 10 && <GuideVassals />}
      </Box>
    </Box>
  );
};

// ============================================
// GUIDE TAB CONTENT COMPONENTS
// ============================================

const GuideBasics = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">The Basics</Box>
    <Box className="VampireGuide__subtitle">
      What every fledgling needs to know
    </Box>
    <Box className="VampireQuote">
      <Box className="VampireQuote__text">
        So you&apos;re a big bad vampire. Congrats.
        <br />
        <strong>Now keep it to yourself.</strong>
      </Box>
      <Box className="VampireQuote__attribution">
        &apos;Smiling&apos; Jack, Los Angeles, circa 2001-2008
      </Box>
    </Box>
    <Box>
      Vampires survive because mortals think they&apos;re myths. That&apos;s the{' '}
      <span className="VampireText--gold">Masquerade</span>. The wolf
      doesn&apos;t want the sheep to know he&apos;s there. Except these sheep
      have guns.
      <strong className="VampireText--blood"> You must stay hidden.</strong>
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Blending In
    </Box>
    <Box>
      You&apos;re dead: no breath, heartbeat, or need for food. That makes you
      stand out. Avoid doctors, health scans, and especially the{' '}
      <span className="VampireText--pink">Curator</span>. They know vampires
      exist and can expose you.
    </Box>
    <Box className="VampireTip VampireTip--info">
      <Box className="VampireTip__label">Tip</Box>
      You have incredible powers, but using them draws attention. Wise kindred
      blend in by acting like mortals. Use a gun instead of claws. Walk instead
      of leaping across rooms. Reserve your powers for when you truly need them.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--green">
      First Steps
    </Box>
    <Box>
      Take a moment to look at your screen. See those icons on the left?
      That&apos;s your vampire HUD. Each icon gives you important information,
      so click through them and learn what they show.
    </Box>
    <Box mt={1}>
      Your next priority should be finding another kindred. They can help you
      learn the ropes, and they might point you toward the local{' '}
      <span className="VampireText--blood">Prince</span>.
    </Box>
    <Box className="VampireRule">
      <Box className="VampireRule__header">#1 Rule of Survival</Box>
      <Box className="VampireRule__main">Keep vitae above 300.</Box>
      <Box className="VampireRule__sub">
        A starving vampire is a dead vampire. Panic leads to mistakes.
      </Box>
      <Box className="VampireRule__footer">
        Feed often. Feed smart. Stay alive.
      </Box>
    </Box>
  </Box>
);

const GuideMasquerade = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">The Masquerade</Box>
    <Box className="VampireGuide__subtitle">
      How to keep from getting us all killed
    </Box>
    <Box>
      The <span className="VampireText--gold">Masquerade</span> is an organized
      disinformation campaign enforced by{' '}
      <span className="VampireText--purple">Kindred</span> society (mainly the{' '}
      <span className="VampireText--purple">Camarilla</span>) to convince humans
      that vampires do not exist.
    </Box>
    <Box mt={2}>
      If a mortal witnesses anything suspicious, you receive a{' '}
      <span className="VampireText--blood">Masquerade Infraction</span>. After{' '}
      <strong>three</strong>, you are exiled and{' '}
      <strong className="VampireText--blood">ALL</strong> vampires turn against
      you.
    </Box>
    <Box mt={2}>
      The <span className="VampireText--pink">Curator</span> possesses the{' '}
      <span className="VampireText--blue">Archive of the Kindred</span>, which
      can instantly expose you. However, if your{' '}
      <span className="VampireText--gold">Masquerade Ability</span> is active,
      even this ancient tome cannot see through your disguise.
    </Box>
    <Box mt={2}>
      At <span className="VampireText--blue">humanity</span> above 7, you gain
      the <span className="VampireText--gold">Masquerade Ability</span>, which
      fools health analyzers and the{' '}
      <span className="VampireText--pink">Curator</span>.{' '}
      <strong>However, you will not heal normally while it is active.</strong>
    </Box>
    <Box className="VampireTip VampireTip--info">
      <Box className="VampireTip__label">Tip</Box>
      Too many patients in the medbay suffering from bloodloss is just as
      obvious as a drained corpse in the halls.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--blood">
      I broke the Masquerade. Now what?
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">
        Everyone hunts you, vampires more than mortals
      </Box>
      <Box className="VampireList__item">Your vassals are up for grabs</Box>
      <Box className="VampireList__item">Other vampires can feed on you</Box>
      <Box className="VampireList__item">
        <strong>Draining another vampire grants you their powers</strong>
      </Box>
      <Box className="VampireList__item">It is too late for mercy</Box>
    </Box>
  </Box>
);

const GuideHumanity = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Humanity</Box>
    <Box className="VampireGuide__subtitle">
      Are we human? Or are we dancer?
    </Box>
    <Box>
      Most <span className="VampireText--purple">Kindred</span> were human
      before their Embrace. Clinging to{' '}
      <span className="VampireText--blue">humanity</span> is how they resist the{' '}
      <span className="VampireText--orange">Beast&apos;s</span> feral nature.
    </Box>
    <Box mt={2}>
      Your <span className="VampireText--blue">humanity</span> directly affects
      the vampiric curse. Lower{' '}
      <span className="VampireText--blue">humanity</span> means:
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">Harder to interact with mortals</Box>
      <Box className="VampireList__item">
        Difficult to stay active during daylight
      </Box>
      <Box className="VampireList__item">
        Longer <span className="VampireText--orange">torpor</span> recovery
      </Box>
    </Box>
    <Box className="VampireTip VampireTip--gold">
      Click the humanity counter on your HUD for detailed information.
    </Box>
    <Box mt={2}>
      Why call it <span className="VampireText--blue">Humanity</span> when not
      all <span className="VampireText--purple">kindred</span> were human?
      Simple: tradition. Centuries-old vampires are slow to change their ways.
    </Box>
  </Box>
);

const GuideSociety = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Princes & Scourges</Box>
    <Box className="VampireGuide__subtitle">The hierarchy of the night</Box>
    <Box>
      A <span className="VampireText--blood">Prince</span> is an elder vampire
      entrusted by the <span className="VampireText--purple">Camarilla</span> to
      rule a territory. They keep track of every{' '}
      <span className="VampireText--purple">kindred</span> present and enforce
      the <span className="VampireText--gold">Masquerade</span> with an iron
      fist.
    </Box>
    <Box mt={2}>
      Of course, they do not work alone. Many{' '}
      <span className="VampireText--blood">Princes</span> employ a{' '}
      <span className="VampireText--blood">Scourge</span>, a personal enforcer
      loyal only to them. Scourges are often chosen from clans like the Tremere,
      though some rare <span className="VampireText--blood">Princes</span> have
      been known to employ even Brujah.
    </Box>
    <Box className="VampireTip VampireTip--info">
      <Box className="VampireTip__label">Important</Box>
      Princes have higher expectations placed upon them. They must protect the
      Masquerade at all costs and deliver final death to misbehaving kindred
      without hesitation.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--purple">
      The Camarilla
    </Box>
    <Box>
      The <span className="VampireText--purple">Camarilla</span> is the most
      organized vampiric sect: an elite club that favors tradition and covert
      control of mortals from behind the scenes. Most vampire clans are part of
      them, though the{' '}
      <span className="VampireText--orange">
        Brujah notably insist on remaining independent
      </span>
      .
    </Box>
    <Box mt={2}>
      Every city, station, colony, or outpost with a{' '}
      <span className="VampireText--purple">kindred</span> presence has a{' '}
      <span className="VampireText--blood">Prince</span> assigned by the{' '}
      <span className="VampireText--purple">Camarilla</span> to oversee it. They
      are the chief enforcers of the{' '}
      <span className="VampireText--gold">Masquerade</span>.
    </Box>
  </Box>
);

const GuideSol = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Sol</Box>
    <Box className="VampireGuide__subtitle">The burning star</Box>
    <Box>
      <span className="VampireText--yellow">Sol</span> refers to the nearby
      temperamental star, not Earth&apos;s sun. Vampires do well in space. You
      are just unlucky enough to be near this one.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Key Facts
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">
        Click the HUD icon for more detailed information
      </Box>
      <Box className="VampireList__item">
        You cannot die to Sol if you are protected by lockers, maintenance
        tunnels, or coffins
      </Box>
      <Box className="VampireList__item">
        If you are caught unprotected, you will burn to dust
      </Box>
      <Box className="VampireList__item">
        Higher humanity grants partial resistance to Sol&apos;s effects
      </Box>
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--blood">
      During Sol
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">
        You cannot passively heal; only coffins can restore you
      </Box>
      <Box className="VampireList__item">
        You take 50% more damage from all sources
      </Box>
      <Box className="VampireList__item">
        Your powers have doubled cooldowns, increased vitae costs, and some are
        blocked entirely
      </Box>
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--blood">
      Growing in Power
    </Box>
    <Box>
      As a vampire, you grow stronger over time by meeting your feeding
      requirements. Click your blood meter on the HUD to see your current
      progress toward the next rank.
    </Box>
    <Box mt={2}>
      After each Sol cycle, if you have consumed enough vitae to meet your goal,
      you will gain a Rank. Each rank provides significant benefits:
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">Increased physical strength</Box>
      <Box className="VampireList__item">Greater health pool</Box>
      <Box className="VampireList__item">Faster feeding rate</Box>
      <Box className="VampireList__item">Higher blood capacity</Box>
      <Box className="VampireList__item">
        Additional discipline points to unlock new powers
      </Box>
    </Box>
  </Box>
);

const GuideVitae = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Vitae</Box>
    <Box className="VampireGuide__subtitle">The blood is the life</Box>
    <Box>
      <span className="VampireText--blood">Vitae</span> is the lifeblood that
      sustains every vampire. The{' '}
      <span className="VampireText--orange">Beast</span> within you demands
      constant feeding, and ignoring this need is not an option. When your blood
      reserves reach zero, you will experience blurred vision, impaired healing,
      and far worse consequences.
    </Box>
    <Box mt={2}>
      Your current rank determines how much{' '}
      <span className="VampireText--blood">vitae</span> you can store and
      utilize at any given time.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Sources of Vitae
    </Box>
    <Box className="VampireList">
      <Box className="VampireList__item">Crewmembers</Box>
      <Box className="VampireList__item">Monkeys</Box>
      <Box className="VampireList__item">Mice</Box>
      <Box className="VampireList__item">Bloodbags</Box>
    </Box>
    <Box className="VampireTip VampireTip--info">
      <Box className="VampireTip__label">Tip</Box>
      Feed from crew regularly. Mice and monkeys will not sustain you in the
      long run.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--orange">
      Frenzy
    </Box>
    <Box>
      When your <span className="VampireText--blood">vitae</span> is completely
      depleted, you lose control and enter a state known as{' '}
      <span className="VampireText--orange">frenzy</span>. In this feral state,
      the <span className="VampireText--orange">Beast</span> takes over and
      compels you to attack the nearest mortal without hesitation.
    </Box>
    <Box mt={2}>
      While in <span className="VampireText--orange">frenzy</span>, you gain the
      ability to grab victims instantly, making you extremely dangerous but also
      highly conspicuous. The only way to regain control of yourself is to feed
      until you have enough <span className="VampireText--blood">vitae</span> to
      suppress the <span className="VampireText--orange">Beast</span>.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--blue">
      Powers & Vitae
    </Box>
    <Box>
      All of your vampiric powers require{' '}
      <span className="VampireText--blood">vitae</span> to use. Some abilities
      drain blood continuously while they remain active, while others have an
      upfront cost when activated. Check the Powers tab for specific costs and
      details on each ability.
    </Box>
  </Box>
);

const GuideCombat = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Combat</Box>
    <Box className="VampireGuide__subtitle">
      Know your strengths and weaknesses
    </Box>
    <Box>
      As a vampire, you have significant advantages in combat, but also critical
      weaknesses that can be exploited.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--green">
      Strengths
    </Box>
    <Box>
      <strong>Enhanced Senses</strong>
    </Box>
    <Box>
      Night vision and thermal vision let you track prey in complete darkness.
    </Box>
    <Box mt={1}>
      <strong>Undead Physiology</strong>
    </Box>
    <Box>
      No need to breathe, sleep, or eat. You are immune to disease. Fatal wounds
      put you into <span className="VampireText--orange">Torpor</span> instead
      of killing you.
    </Box>
    <Box mt={1}>
      <strong>Resilience</strong>
    </Box>
    <Box>
      Immune to cold, radiation, and toxins. Critical injuries do not knock you
      down.
    </Box>
    <Box mt={1}>
      <strong>Supernatural Strength</strong>
    </Box>
    <Box>Your fists deal devastating damage, scaling with your rank.</Box>
    <Box mt={2} className="VampireSectionHeader VampireSectionHeader--blood">
      Weaknesses
    </Box>
    <Box>
      <strong>Stakes</strong>
    </Box>
    <Box>
      Paralyze you, disable powers, halt healing, and prevent revival from{' '}
      <span className="VampireText--orange">Torpor</span>.
    </Box>
    <Box mt={1}>
      <strong>Fire and Lasers</strong>
    </Box>
    <Box>Deal devastating damage. Fortitude offers minimal protection.</Box>
    <Box mt={1}>
      <strong>Sol</strong>
    </Box>
    <Box>
      Every ten minutes, sunlight cripples you unless protected by a coffin or
      similar shelter.
    </Box>
    <Box mt={1}>
      <strong>The Masquerade</strong>
    </Box>
    <Box>
      Break it and every vampire turns against you. You will be hunted by
      kindred and mortals alike.
    </Box>
  </Box>
);

const GuideLair = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Your Lair</Box>
    <Box className="VampireGuide__subtitle">A place to call your own</Box>
    <Box>
      A <span className="VampireText--green">lair</span> is a location you have
      claimed as your own, where you can rest in your coffin and perform certain
      vampiric rituals. Some vampires find them useful. Many more have been
      caught because of them.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Do You Need a Lair?
    </Box>
    <Box>
      Honestly? Probably not. A <span className="VampireText--green">lair</span>{' '}
      is only necessary if you intend to create{' '}
      <span className="VampireText--purple">vassals</span> or use certain
      structures. If you just need somewhere to hide during{' '}
      <span className="VampireText--yellow">Sol</span>, any dark corner with a
      locker will do. The more infrastructure you build, the more evidence you
      leave behind.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Claiming a Lair
    </Box>
    <Box>
      If you still want one: acquire a coffin from the Chapel or craft one via
      the Furniture category. Find somewhere <em>truly hidden</em>, place the
      coffin, and rest inside to claim the area. Once claimed, you can anchor
      vampiric structures like the{' '}
      <span className="VampireText--purple">Vassalization Rack</span> or{' '}
      <span className="VampireText--blood">Blood Throne</span>.
    </Box>
    <Box className="VampireTip VampireTip--warning">
      <Box className="VampireTip__label">Warning</Box>
      Maintenance is the first place people look. If someone finds your lair,
      they find everything: your coffin, your structures, your vassals, and you.
    </Box>
  </Box>
);

const GuideStructures = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Structures</Box>
    <Box className="VampireGuide__subtitle">
      These can be built via the Vampire crafting tab
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--purple">
      Vassalization Rack
    </Box>
    <Box>
      The vassalization rack is your tool for converting captured crewmembers
      into loyal <span className="VampireText--purple">vassals</span> who will
      serve your every command.
    </Box>
    <Box mt={1}>
      <strong>Usage:</strong> Secure the rack in your{' '}
      <span className="VampireText--green">lair</span> → restrain your target →
      drag them onto the rack → click the rack to begin the torture process.
    </Box>
    <Box mt={1}>
      You can speed up the conversion significantly by using{' '}
      <span className="VampireText--blood">sharp tools</span> on the victim
      while they are restrained.
    </Box>
    <Box mt={2}>
      Crewmembers with <span className="VampireText--blue">mindshields</span> or
      strong loyalties require their mental defenses to be weakened first.{' '}
      <span className="VampireText--purple">Eldritch servants</span> are
      completely immune and can never be converted.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Candelabrum
    </Box>
    <Box>
      A vampiric candelabra that radiates an unsettling aura. Any mortal who
      gazes upon its <span className="VampireText--orange">flame</span> will
      find their sanity slowly draining away.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--blood">
      Blood Throne
    </Box>
    <Box>
      When you sit upon a Blood Throne, your words are broadcast telepathically
      to all <span className="VampireText--purple">kindred</span> on the
      station. Other vampires will need their own throne if they wish to
      respond.
    </Box>
  </Box>
);

const GuideVassals = () => (
  <Box className="VampireGuide__text">
    <Box className="VampireGuide__title">Vassals</Box>
    <Box className="VampireGuide__subtitle">Servants of the blood</Box>
    <Box>
      <span className="VampireText--purple">Vassals</span> are mortals who have
      been broken and bound to your will. They serve as your eyes, ears, and
      hands among the living, carrying out your commands while you remain hidden
      in the shadows.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Creating Vassals
    </Box>
    <Box>
      To create a vassal, you will need a{' '}
      <span className="VampireText--purple">Vassalization Rack</span> secured
      within your <span className="VampireText--green">lair</span>. Capture your
      target and restrain them so they cannot escape, then drag them onto the
      rack. Click the rack to begin the{' '}
      <span className="VampireText--blood">torture</span> process that will
      break their will and bind them to you.
    </Box>
    <Box mt={1}>
      Using <span className="VampireText--blood">sharp implements</span> on the
      victim while they are restrained will accelerate the process considerably.
    </Box>
    <Box className="VampireSectionHeader VampireSectionHeader--gold">
      Limitations
    </Box>
    <Box>
      Crewmembers protected by{' '}
      <span className="VampireText--blue">mindshields</span> or those with
      strong existing loyalties cannot be converted until their mental defenses
      have been weakened. Those who serve{' '}
      <span className="VampireText--purple">eldritch powers</span> are
      completely immune and can never be turned.
    </Box>
    <Box mt={2}>
      Once someone has become your vassal, the only way to free them is through
      implantation of a <span className="VampireText--blue">mindshield</span>.
    </Box>
  </Box>
);
const PowerSection = (_props) => {
  const { data } = useBackend<VampireInformation>();
  const { powers } = data;
  if (!powers) {
    return <Section minHeight="220px" />;
  }

  const [tab, setTab] = useLocalState('powerTab', 0);
  return (
    <Box className="VampirePowers" style={{ height: '100%' }}>
      <Box className="VampirePowers__sidebar">
        {powers.map((power, index) => (
          <Box
            key={index}
            className={`VampirePowers__tab ${tab === index ? 'VampirePowers__tab--selected' : ''}`}
            onClick={() => setTab(index)}
          >
            <Box className="VampirePowers__tab-icon">
              <DmIcon
                icon={power.icon}
                icon_state={power.icon_state}
                fallback={<Icon name="spinner" spin fontSize="24px" />}
                width="32px"
                style={{ imageRendering: 'pixelated' }}
              />
            </Box>
            {power.name}
          </Box>
        ))}
      </Box>
      <Box className="VampirePowers__content">
        {powers.map(
          (power, index) =>
            tab === index && (
              <Box key={index}>
                <Box className="VampirePowers__powerName">{power.name}</Box>
                {(power.cost !== '0' ||
                  power.constant_cost !== '0' ||
                  power.cooldown !== '0') && (
                  <Box className="VampirePowers__stats">
                    {power.cost !== '0' && (
                      <Box className="VampirePowers__stat">
                        <Box className="VampirePowers__stat-label">
                          Blood Cost
                        </Box>
                        <Box className="VampirePowers__stat-value">
                          {power.cost}
                        </Box>
                      </Box>
                    )}
                    {power.constant_cost !== '0' && (
                      <Box className="VampirePowers__stat">
                        <Box className="VampirePowers__stat-label">
                          Blood Drain
                        </Box>
                        <Box className="VampirePowers__stat-value">
                          {power.constant_cost}/s
                        </Box>
                      </Box>
                    )}
                    {power.cooldown !== '0' && (
                      <Box className="VampirePowers__stat">
                        <Box className="VampirePowers__stat-label">
                          Cooldown
                        </Box>
                        <Box className="VampirePowers__stat-value">
                          {power.cooldown}s
                        </Box>
                      </Box>
                    )}
                  </Box>
                )}
                <Box
                  className="VampirePowers__description"
                  dangerouslySetInnerHTML={{
                    __html: sanitizeText(
                      power.explanation.replace(/\n/g, '<br/><br/>'),
                    ),
                  }}
                />
              </Box>
            ),
        )}
      </Box>
    </Box>
  );
};

const ClanSection = () => {
  const { data } = useBackend<VampireInformation>();
  const { clan, in_clan } = data;

  if (!in_clan) {
    return (
      <Box className="VampireClan">
        <Box className="VampireClan__noClan">
          <Box className="VampireClan__noClan-title">
            You are not in a clan!
          </Box>
          <Box className="VampireClan__noClan-text">
            To determine your clan, utilize the clan selection ability.
          </Box>
        </Box>
      </Box>
    );
  }

  return (
    <Box>
      {clan.map((ClanInfo, index) => (
        <Box key={index} className="VampireClan">
          <Box className="VampireClan__portrait">
            <DmIcon
              icon={ClanInfo.icon}
              icon_state={ClanInfo.icon_state}
              fallback={<Icon name="spinner" spin fontSize="30px" />}
              width="128px"
              style={{ imageRendering: 'pixelated' }}
            />
          </Box>
          <Box className="VampireClan__info">
            <Box className="VampireClan__name">The {ClanInfo.name}</Box>
            <Box
              className="VampireClan__description"
              dangerouslySetInnerHTML={{ __html: ClanInfo.description }}
            />
          </Box>
        </Box>
      ))}
    </Box>
  );
};
