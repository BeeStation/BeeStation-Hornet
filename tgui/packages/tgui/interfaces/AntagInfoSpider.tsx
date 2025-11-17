import { resolveAsset } from '../assets';
import { useBackend, useLocalState } from '../backend';
import { BlockQuote, Box, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';

type Info = {
  directive?: string;
  master?: string;
  type: string;
  color: string;
};

const default_spider_tab = {
  broodmother: 1,
  guard: 2,
  nurse: 3,
  'ice nurse': 3,
  'net caster': 4,
  hunter: 5,
  'ice hunter': 5,
  viper: 6,
};
const default_spider_image = 'spidertarantula.png';
const spider_image = {
  broodmother: 'spiderbroodmother.png',
  guard: 'spiderguard.png',
  nurse: 'spidernurse.png',
  'ice nurse': 'spidernurse.png',
  hunter: 'spiderhunter.png',
  'ice hunter': 'spiderhunter.png',
  viper: 'spiderviper.png',
};
const colors = {
  hp: 'red',
  damage: 'orange',
  venom: 'purple',
  ability: 'yellow',
};
const image_style = {
  msInterpolationMode: 'nearest-neighbor',
  imageRendering: 'pixelated',
  float: 'left',
};

const BasicInfoSection = (_props) => {
  const { data } = useBackend<Info>();
  const { color } = data;
  return (
    <Section>
      You are a{' '}
      <Box inline textColor={color}>
        giant spider
      </Box>{' '}
      trying to make a new nest to thrive with your brood. This station is rich
      with food to sustain your efforts, but your prey will fight back.
      Strategize and coordinate your unique abilities alongside your broodmates
      and follow the directions of the broodmother(s) in order to succeed!
    </Section>
  );
};

const DirectiveSection = (_props) => {
  const { data } = useBackend<Info>();
  const { directive } = data;
  return (
    <Section title="Directive">
      {(directive && (
        <Stack vertical>
          <Stack.Item>
            <BlockQuote>{directive}</BlockQuote>
          </Stack.Item>
          <Stack.Item>
            <Box bold italic textColor="red">
              Ensure you follow this directive at all costs!
            </Box>
          </Stack.Item>
        </Stack>
      )) || (
        <Box bold italic>
          You do not have a directive. You&apos;ll need to set one before laying
          eggs.
        </Box>
      )}
    </Section>
  );
};

const AbilitiesSection = (_props) => {
  return (
    <Section title="Abilities">
      <p>
        You can vent crawl by pressing [
        <Box inline textColor={colors.ability}>
          ALT + CLICK
        </Box>
        ] on any vent. Utilize vents for surprise attacks and also to get away
        from attackers and regroup elsewhere when overwhelmed.
      </p>
      <p>
        Use [
        <Box inline textColor={colors.ability}>
          SPIN WEB
        </Box>
        ] to lay down sticky webs where you currently are. Webs may be placed up
        to three times in the same location and they will block projectiles as
        well as impede everything that attempts to cross them except for your
        broodmates. Grab and drag prey through webs to prevent them from moving,
        but be aware they can still fight back while being pulled!
      </p>
      <p>
        Use [
        <Box inline textColor={colors.ability}>
          WRAP
        </Box>
        ] to encase items in sticky web to prevent your prey from using them
        against you. Sometimes their tools and weapons may become stuck in your
        webs as they try in vain to resist.{' '}
        <i>
          Only broodmothers are able to [
          <Box inline textColor={colors.ability}>
            WRAP
          </Box>
          ] prey and consume them!
        </i>
      </p>
      <p>
        All of your direct attacks will inject [
        <Box inline textColor={colors.venom}>
          SPIDER VENOM
        </Box>
        ] into your prey, which will inhibit their movements and eventually
        result in paralysis. This venom is the most powerful tool available for
        most spiders, and should be relied upon more than brute force. Bite and
        run, and only continue to fight after it has begun to set in!
      </p>
    </Section>
  );
};

const SpiderTypesSection = (_props) => {
  const { data } = useBackend<Info>();
  const { type } = data;
  const [tab, setTab] = useLocalState('tab', default_spider_tab[type] || 1);
  return (
    <Section title="Spider Types">
      <Tabs>
        <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
          <Box inline bold={default_spider_tab[type] === 1}>
            Broodmother
          </Box>
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
          <Box inline bold={default_spider_tab[type] === 2}>
            Guard
          </Box>
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
          <Box inline bold={default_spider_tab[type] === 3}>
            Nurse
          </Box>
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
          <Box inline bold={default_spider_tab[type] === 4}>
            Net Caster
          </Box>
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
          <Box inline bold={default_spider_tab[type] === 5}>
            Hunter
          </Box>
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
          <Box inline bold={default_spider_tab[type] === 6}>
            Viper
          </Box>
        </Tabs.Tab>
      </Tabs>
      {tab === 1 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spiderbroodmother.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The matriarch of the brood that all other spiders should generally
            obey, protect and serve.
          </p>
          <p>
            Broodmothers have [
            <Box inline textColor={colors.hp}>
              High HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Moderate Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Potent Venom
            </Box>
            ].
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Broodmothers are able to [
            <Box inline textColor={colors.ability}>
              WRAP
            </Box>
            ] prey to feed on them, which will enable your ability to [
            <Box inline textColor={colors.ability}>
              LAY EGGS
            </Box>
            ] and expand the size of the brood. Lay eggs in safe, protected
            locations and try not to put all your eggs in one basket.
          </p>
          <p>
            Broodmothers can communicate with all other living spiders
            regardless of distance by using [
            <Box inline textColor={colors.ability}>
              COMMAND
            </Box>
            ]. You can use [
            <Box inline textColor={colors.ability}>
              SET DIRECTIVE
            </Box>
            ] to to issue a new focus for the brood which will be given even to
            freshly hatched spiders.
          </p>
          <p>
            Broodmothers are able to lay webs faster than all other spiders, and
            should spend any spare time you have expanding the nest to give your
            brood a safe haven to retreat to.
          </p>
          <p>
            Broodmothers are very capable of defending themselves with pretty
            high stats all around, but should do everything they can to avoid
            combat because of how important they are to the longevity of the
            brood.
          </p>
        </Box>
      )}
      {tab === 2 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spiderguard.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The stout warriors of the brood that should generally stay with
            established nests and near the broodmother.
          </p>
          <p>
            Guards have [
            <Box inline textColor={colors.hp}>
              Very High HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Very High Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Weak Venom
            </Box>
            ].
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Guards can use their [
            <Box inline textColor={colors.ability}>
              BLOCK
            </Box>
            ] ability to prevent others from passing around them and block
            doorways or even trap prey within nests. Toggle it off to enable
            broodmates to pass around when navigating in tight spaces.
          </p>
          <p>
            Guards have the highest HP and raw damage output out of all other
            spiders in the brood, but their venom is especially sparse and
            should not be relied upon to have much effect without support from a
            more venomous spider
          </p>
          <p>
            Guards are able to lay webs faster than most other spiders and
            should help with expanding the nest they are currently guarding when
            not under attack.
          </p>
        </Box>
      )}
      {tab === 3 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spidernurse.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The medics of the brood that should generally stay near guards or
            deeper within nests where they can heal spiders that have retreated
            from battle.
          </p>
          <p>
            Nurses have [
            <Box inline textColor={colors.hp}>
              Low HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Low Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Moderate Venom
            </Box>
            ] and should avoid combat at any cost, as they rival the broodmother
            in terms of importance to the brood.
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Nurses are able to see the health of other spiders as well as heal
            the wounds of spiders (including themselves) by clicking on them.
          </p>
          <p>
            Nurses are also able to lay webs almost as fast as broodmothers can
            and should help with expanding nesting sites when spiders are not in
            need of care.
          </p>
          <p>
            When nests are under attack, nurses should support guards blocking
            doorways by keeping them topped up, but be ready to retreat when
            guards pull prey into the web.
          </p>
        </Box>
      )}
      {tab === 4 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spidertarantula.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The well-rounded spider that&apos;s a useful to have in any
            situation, but should avoid being caught alone.
          </p>
          <p>
            Net Casters have [
            <Box inline textColor={colors.hp}>
              High HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Moderate Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Moderate Venom
            </Box>
            ].
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Net casters can use [
            <Box inline textColor={colors.ability}>
              THROW WEB
            </Box>
            ] to spin a web into their forelimbs rather than onto the ground.
            This web may then be thrown to place webbing at a distance to block
            doorways, or to hit prey directly to knock them over and inhibit
            their movement temporarily. Webs are easily thrown past your brood
            so there is no risk of entangling your own team!
          </p>
          <p>
            While slower and a bit less damaging than hunters, Net Casters still
            move relatively quickly away from webs making them a good companion
            for hunting efforts. Likewise their ability to disable attackers
            from a range makes them an invaluable support for guards defending a
            nest.
          </p>
        </Box>
      )}
      {tab === 5 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spiderhunter.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The fast and powerful hunters of the brood that seek and bring prey
            back to the nest.
          </p>
          <p>
            Hunters have [
            <Box inline textColor={colors.hp}>
              Moderate HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Moderate Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Potent Venom
            </Box>
            ] as well as high speed even without webs to boost them.
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Hunters move quickly, have the second highest raw damage output
            behind guards and the second highest venom output behind vipers, but
            have no special abilities beyond these raw stats.
          </p>
          <p>
            Hunters can lay webs as a trap near vents and ambush prey that
            wanders too close. Remember that while you can utilize vents for
            surprise attacks, you cannot drag prey through vents back to the
            nest, so don&apos;t wander too far away for ambushes.
          </p>
        </Box>
      )}
      {tab === 6 && (
        <Box>
          <Box
            inline
            as="img"
            src={resolveAsset('spiderviper.png')}
            width="48px"
            style={image_style}
          />
          <p>
            The assassins of the brood that possess a substantially more
            powerful venom than the rest of the brood, but are very fragile.
          </p>
          <p>
            Vipers have [
            <Box inline textColor={colors.hp}>
              Low HP
            </Box>
            ], [
            <Box inline textColor={colors.damage}>
              Low Damage
            </Box>
            ] and [
            <Box inline textColor={colors.venom}>
              Lethal Venom
            </Box>
            ].
          </p>
          <h2>Special Capabilities</h2>
          <p>
            Vipers have venom that is so lethal a single bite is all that is
            necessary to kill most prey, however their venom lacks the paralytic
            properties that other spiders&apos; venom carries.
          </p>
          <p>
            While vipers move as fast as hunters away from nests, they are even
            faster than hunters when guarding a nest and can utilize their
            lethal venom to repel attackers from relative safety if they choose
            to defend nests.
          </p>
          <p>
            Vipers are extremely fragile and can rarely survive more than two
            attacks. Do not prolong engagements more than is necessary and
            always have a web to retreat behind somewhere nearby.
          </p>
        </Box>
      )}
    </Section>
  );
};

export const AntagInfoSpider = (_props) => {
  const { data } = useBackend<Info>();
  const { color, type } = data;
  return (
    <Window width={700} height={850} theme="neutral">
      <Window.Content scrollable>
        <Stack vertical grow>
          <Stack.Item>
            <AntagInfoHeader
              name="Spider"
              color={color}
              asset={spider_image[type] || default_spider_image}
            />
          </Stack.Item>
          <Stack.Item>
            <BasicInfoSection />
          </Stack.Item>
          <Stack.Item>
            <DirectiveSection />
          </Stack.Item>
          <Stack.Item>
            <AbilitiesSection />
          </Stack.Item>
          <Stack.Item>
            <SpiderTypesSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
