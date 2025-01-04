import { BooleanLike } from 'common/react';
import { multiline } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Dimmer, Divider, Icon, Input, NoticeBox, ProgressBar, Section, Stack } from '../components';
import { Window } from '../layouts';
import { InfernoNode } from 'inferno';

enum SpellCategory {
  Offensive = 'Offensive',
  Defensive = 'Defensive',
  Mobility = 'Mobility',
  Assistance = 'Assistance',
  Rituals = 'Rituals',
}

type byondRef = string;

type SpellEntry = {
  // Name of the spell
  name: string;
  // Description of what the spell does
  desc: string;
  // Byond REF of the spell entry datum
  ref: byondRef;
  // Whether the spell requires wizard clothing to cast
  clothes_req: BooleanLike;
  // Spell points required to buy the spell
  cost: number;
  // How many times the spell has been bought
  times: number;
  // Cooldown length of the spell once cast once
  cooldown: number;
  // Category of the spell
  cat: SpellCategory;
  // Whether the spell is refundable
  refundable: BooleanLike;
  // // How many times the spell can been bought
  limit: number;
  // The verb displayed when buying
  buyword: Buywords;
};

type Data = {
  owner: string;
  points: number;
  entries: SpellEntry[];
};

type TabType = {
  title: string;
  blurb?: string;
  component?: () => InfernoNode;
  locked?: boolean;
  scrollable?: boolean;
};

const TAB2NAME: TabType[] = [
  {
    title: 'Enscribed Name',
    blurb:
      "This book answers only to its owner, and of course, must have one. The permanence of the pact between a spellbook and its owner ensures such a powerful artifact cannot fall into enemy hands, or be used in ways that break the Federation's rules such as bartering spells.",
    component: () => <EnscribedName />,
  },
  {
    title: 'Table of Contents',
    component: () => <TableOfContents />,
  },
  {
    title: 'Offensive',
    blurb: 'Spells and items geared towards debilitating and destroying.',
    scrollable: true,
  },
  {
    title: 'Defensive',
    blurb: "Spells and items geared towards improving your survivability or reducing foes' ability to attack.",
    scrollable: true,
  },
  {
    title: 'Mobility',
    blurb: 'Spells and items geared towards improving your ability to move. It is a good idea to take at least one.',
    scrollable: true,
  },
  {
    title: 'Assistance',
    blurb:
      'Spells and items geared towards bringing in outside forces to aid you or improving upon your other items and abilities.',
    scrollable: true,
  },
  {
    title: 'Challenges',
    blurb:
      'The Wizard Federation is looking for shows of power. Arming the station against you will increase the danger, but will grant you more charges for your spellbook.',
    locked: true,
    scrollable: true,
  },
  {
    title: 'Rituals',
    blurb: 'These powerful spells change the very fabric of reality. Not always in your favour.',
    scrollable: true,
  },
  {
    title: 'Loadouts',
    blurb:
      'The Wizard Federation accepts that sometimes, choosing is hard. You can choose from some approved wizard loadouts here.',
    component: () => <Loadouts />,
  },
  {
    title: 'Randomize',
    blurb: "If you didn't like the loadouts offered, you can embrace chaos. Not recommended for newer wizards.",
    component: () => <Randomize />,
  },
];

enum Buywords {
  Learn = 'Learn',
  Summon = 'Summon',
  Cast = 'Cast',
}

const BUYWORD2ICON = {
  Learn: 'plus',
  Summon: 'hat-wizard',
  Cast: 'meteor',
};

const EnscribedName = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { owner } = data;
  return (
    <>
      <Box mt={25} mb={-3} fontSize="50px" color="bad" textAlign="center" fontFamily="Ink Free">
        {owner}
      </Box>
      <Divider />
    </>
  );
};

const lineHeightToc = '34.6px';

const TableOfContents = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  return (
    <Box textAlign="center">
      <Button lineHeight={lineHeightToc} fluid icon="pen" disabled content="Name Enscription" />
      <Button lineHeight={lineHeightToc} fluid icon="clipboard" disabled content="Table of Contents" />
      <Divider />
      <Button lineHeight={lineHeightToc} fluid icon="fire" content="Deadly Evocations" onClick={() => setTabIndex(3)} />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        content="Defensive Evocations"
        onClick={() => setTabIndex(4)}
      />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        content="Magical Transportation"
        onClick={() => setTabIndex(5)}
      />
      <Button lineHeight={lineHeightToc} fluid icon="users" content="Assistance and Summoning" onClick={() => setTabIndex(6)} />
      <Divider />
      <Button lineHeight={lineHeightToc} fluid icon="crown" content="Challenges" onClick={() => setTabIndex(7)} />
      <Button lineHeight={lineHeightToc} fluid icon="magic" content="Rituals" onClick={() => setTabIndex(8)} />
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="thumbs-up"
        content="Wizard Approved Loadouts"
        onClick={() => setTabIndex(9)}
      />
      <Button lineHeight={lineHeightToc} fluid icon="dice" content="Arcane Randomizer" onClick={() => setTabIndex(10)} />
    </Box>
  );
};

const LockedPage = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { owner } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item align="center">
          <Icon color="purple" name="lock" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          The Wizard Federation has locked this page.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const PointLocked = (props, context) => {
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item align="center">
          <Icon color="purple" name="dollar-sign" size={10} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="purple">
          You do not have enough points to use this page.
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

type WizardLoadout = {
  loadoutId: string;
  loadoutColor: string;
  name: string;
  blurb: string;
  icon: string;
  author: string;
};

const SingleLoadout = (props: WizardLoadout, context) => {
  const { act } = useBackend<WizardLoadout>(context);
  const { author, name, blurb, icon, loadoutId, loadoutColor } = props;
  return (
    <Stack.Item grow>
      <Section width={LoadoutWidth} title={name}>
        {blurb}
        <Divider />
        <Button.Confirm
          confirmContent="Confirm Purchase?"
          confirmIcon="dollar-sign"
          confirmColor="good"
          fluid
          icon={icon}
          content="Purchase Loadout"
          onClick={() =>
            act('purchase_loadout', {
              id: loadoutId,
            })
          }
        />
        <Divider />
        <Box color={loadoutColor}>Added by {author}.</Box>
      </Section>
    </Stack.Item>
  );
};

const LoadoutWidth = 19.17;

const Loadouts = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { points } = data;
  // Future todo : Make these datums on the DM side
  return (
    <Stack ml={0.5} mt={-0.5} vertical fill>
      {points < 10 && <PointLocked />}
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            loadoutId="loadout_classic"
            loadoutColor="purple"
            name="The Classic Wizard"
            icon="fire"
            author="Archchancellor Gray"
            blurb={multiline`
                This is the classic wizard, crazy popular in
                the 2550's. Comes with Fireball, Magic Missile,
                Disintegrate, and Ethereal Jaunt. The key here is that
                every part of this kit is very easy to pick up and use.
              `}
          />
          <SingleLoadout
            name="Mjolnir's Power"
            icon="hammer"
            loadoutId="loadout_hammer"
            loadoutColor="green"
            author="Jegudiel Worldshaker"
            blurb={multiline`
                The power of the mighty Mjolnir! Best not to lose it.
                This loadout has Summon Item, Mutate, Blink, Force Wall,
                Tesla Blast, Repulse and Mjolnir. Mutate is your utility in this case:
                Use it for limited ranged fire and getting out of bad blinks.
              `}
          />
        </Stack>
      </Stack.Item>
      <Stack.Item>
        <Stack fill>
          <SingleLoadout
            name="Fantastical Army"
            icon="pastafarianism"
            loadoutId="loadout_army"
            loadoutColor="yellow"
            author="Prospero Spellstone"
            blurb={multiline`
                Why kill when others will gladly do it for you?
                Embrace chaos with your kit: Soulshards, Staff of Change,
                Necro Stone, Teleport, and Jaunt! Remember, no offense spells!
              `}
          />
          <SingleLoadout
            name="Soul Tapper"
            icon="skull"
            loadoutId="loadout_tap"
            loadoutColor="white"
            author="Tom the Empty"
            blurb={multiline`
                Embrace the dark, and tap into your soul.
                You can recharge very long recharge spells
                like Disintegrate by jumping into new bodies with
                Mind Swap and starting Soul Tap anew.
              `}
          />
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const lineHeightRandomize = 6;

const Randomize = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { points } = data;
  return (
    <Stack fill vertical>
      {points < 10 && <PointLocked />}
      <Stack.Item>Semi-Randomize will ensure you at least get some mobility and lethality.</Stack.Item>
      <Stack.Item>
        <Button.Confirm
          confirmContent="Cowabunga it is?"
          confirmIcon="dice-three"
          lineHeight={lineHeightRandomize}
          fluid
          icon="dice-three"
          content="Semi-Randomize!"
          onClick={() => act('semirandomize')}
        />
        <Divider />
      </Stack.Item>
      <Stack.Item>Full Random will give you anything. There&apos;s no going back, either!</Stack.Item>
      <Stack.Item>
        <NoticeBox danger>
          <Button.Confirm
            confirmContent="Cowabunga it is?"
            confirmIcon="dice"
            lineHeight={lineHeightRandomize}
            fluid
            color="black"
            icon="dice"
            content="Full Random!"
            onClick={() => act('randomize')}
          />
        </NoticeBox>
      </Stack.Item>
    </Stack>
  );
};

const SearchSpells = (props, context) => {
  const { data } = useBackend<Data>(context);
  const [spellSearch] = useLocalState(context, 'spell-search', '');
  const { entries } = data;

  const filterEntryList = (entries: SpellEntry[]) => {
    const searchStatement = spellSearch.toLowerCase();
    if (searchStatement === 'robeless') {
      // Lets you just search for robeless spells, you're welcome mindswap-bros
      return entries.filter((entry) => !entry.clothes_req);
    }

    return entries.filter(
      (entry) =>
        entry.name.toLowerCase().includes(searchStatement) ||
        // Unsure about including description. Wizard spell descriptions
        // are painfully original and use the same verbiage often,
        // which may both be a benefit and a curse
        entry.desc.toLowerCase().includes(searchStatement) ||
        // Also opting to include category
        // so you can search "rituals" to see them all at once
        entry.cat.toLowerCase().includes(searchStatement)
    );
  };

  const filteredEntries = filterEntryList(entries);

  if (filteredEntries.length === 0) {
    return (
      <Stack width="100%" vertical>
        <Stack.Item>
          <NoticeBox>{`No spells found!`}</NoticeBox>
        </Stack.Item>
        <Stack.Item>
          <Box italic align="center" color="lightgrey">
            {`Search tip: Searching "Robeless" will only show you
            spells that don't require wizard garb!`}
          </Box>
        </Stack.Item>
      </Stack>
    );
  }
  return <SpellTabDisplay TabSpells={filteredEntries} />;
};

const SpellTabDisplay = (
  props: {
    TabSpells: SpellEntry[];
  },
  context
) => {
  const { act, data } = useBackend<Data>(context);
  const { points } = data;
  const { TabSpells } = props;

  const getTimeOrCat = (entry: SpellEntry) => {
    if (entry.cat === SpellCategory.Rituals) {
      if (entry.times) {
        return `Cast ${entry.times} times.`;
      } else {
        return 'Not cast yet.';
      }
    } else {
      if (entry.cooldown) {
        return `${entry.cooldown}s Cooldown`;
      } else if (entry.limit) {
        return `Maximum: ${entry.limit}`;
      } else {
        return '';
      }
    }
  };

  return (
    <Stack vertical>
      {TabSpells.sort((a, b) => a.name.localeCompare(b.name)).map((entry) => (
        <Stack.Item key={entry.name}>
          <Divider />
          <Stack mt={1.3} width="100%" position="absolute" textAlign="left">
            <Stack.Item width="100px" ml={40}>
              {getTimeOrCat(entry)}
            </Stack.Item>
            <Stack.Item width="60px">{entry.cost} points</Stack.Item>
          </Stack>
          <Section
            title={entry.name}
            buttons={
              entry.buyword === Buywords.Learn && (
                <Button
                  mt={-0.8}
                  icon="tshirt"
                  color={entry.clothes_req ? 'bad' : 'green'}
                  tooltipPosition="bottom-start"
                  tooltip={entry.clothes_req ? 'Requires wizard garb.' : 'Can be cast without wizard garb.'}
                />
              )
            }>
            <Stack>
              <Stack.Item grow>{entry.desc}</Stack.Item>
              <Stack.Item>
                <Divider vertical />
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  textAlign="center"
                  color={points >= entry.cost ? 'green' : 'bad'}
                  disabled={points < entry.cost || entry.limit === 0}
                  width={7}
                  icon={BUYWORD2ICON[entry.buyword]}
                  content={entry.buyword}
                  onClick={() =>
                    act('purchase', {
                      spellref: entry.ref,
                    })
                  }
                />
                <br />
                {(!entry.refundable && <NoticeBox>No refunds.</NoticeBox>) || (
                  <Button
                    textAlign="center"
                    width={7}
                    icon="arrow-left"
                    content="Refund"
                    onClick={() =>
                      act('refund', {
                        spellref: entry.ref,
                      })
                    }
                  />
                )}
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};

const CategoryDisplay = (props: { ActiveCat: TabType }, context) => {
  const { data } = useBackend<Data>(context);
  const { entries } = data;
  const { ActiveCat } = props;

  const TabSpells = entries.filter((entry) => entry.cat === ActiveCat.title);

  return (
    <>
      {!!ActiveCat.locked && <LockedPage />}
      <Stack vertical>
        {ActiveCat.blurb && (
          <Stack.Item>
            <Box textAlign="center" bold height="30px">
              {ActiveCat.blurb}
            </Box>
          </Stack.Item>
        )}
        <Stack.Item>{(ActiveCat.component && ActiveCat.component()) || <SpellTabDisplay TabSpells={TabSpells} />}</Stack.Item>
      </Stack>
    </>
  );
};

const widthSection = '486px';
const heightSection = '546px';

export const Spellbook = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { points } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tab-index', 1);
  const [spellSearch, setSpellSearch] = useLocalState(context, 'spell-search', '');
  const ActiveCat = TAB2NAME[tabIndex - 1];
  const ActiveNextCat = TAB2NAME[tabIndex];

  // Has a chance of selecting a random funny verb instead of "Searching"
  const SelectSearchVerb = () => {
    let found = Math.random();
    if (found <= 0.03) {
      return 'Seeking';
    }
    if (found <= 0.06) {
      return 'Contemplating';
    }
    if (found <= 0.09) {
      return 'Divining';
    }
    if (found <= 0.12) {
      return 'Scrying';
    }
    if (found <= 0.15) {
      return 'Peeking';
    }
    if (found <= 0.18) {
      return 'Pondering';
    }
    if (found <= 0.21) {
      return 'Divining';
    }
    if (found <= 0.24) {
      return 'Gazing';
    }
    if (found <= 0.27) {
      return 'Studying';
    }
    if (found <= 0.3) {
      return 'Reviewing';
    }

    return 'Searching';
  };

  const SelectedVerb = SelectSearchVerb();

  return (
    <Window title="Spellbook" theme="wizard" width={500} height={640}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack fill>
              {spellSearch.length > 1 ? (
                <Stack.Item grow>
                  <Section
                    title={`${SelectedVerb}...`}
                    scrollable
                    height={heightSection}
                    fill
                    buttons={
                      <Button content={`Stop ${SelectedVerb}`} icon="arrow-rotate-left" onClick={() => setSpellSearch('')} />
                    }>
                    <SearchSpells />
                  </Section>
                </Stack.Item>
              ) : (
                <Stack.Item grow>
                  <Section
                    scrollable={ActiveCat.scrollable}
                    width={widthSection}
                    height={heightSection}
                    fill
                    title={ActiveCat.title}
                    buttons={
                      <>
                        <Button
                          disabled={tabIndex === 1}
                          icon="arrow-left"
                          content="Previous Page"
                          onClick={() => setTabIndex(tabIndex - 1)}
                        />
                        <Button disabled={tabIndex === 2} icon="home" content="TOC" onClick={() => setTabIndex(2)} />
                        <Button
                          icon="arrow-right"
                          disabled={tabIndex === 10}
                          content="Next Page"
                          onClick={() => setTabIndex(tabIndex + 1)}
                        />
                      </>
                    }>
                    <CategoryDisplay ActiveCat={ActiveCat} />
                  </Section>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item grow>
                  <ProgressBar value={points / 10}>{points + ' points left to spend.'}</ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    width={15}
                    placeholder="Search for a spell..."
                    icon="search"
                    onInput={(e, val) => setSpellSearch(val)}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
