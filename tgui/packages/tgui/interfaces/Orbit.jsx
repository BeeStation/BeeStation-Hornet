import { createSearch } from 'common/string';
import { resolveAsset } from '../assets';
import { Box, Button, Input, Icon, Section, Flex } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';
import { CollapsibleSection } from 'tgui/components/CollapsibleSection';

const PATTERN_DESCRIPTOR = / \[(?:ghost|dead)\]$/;
const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = (searchText) => createSearch(searchText, (thing) => thing.name);

const compareString = (a, b) => (a < b ? -1 : a > b);

const compareNumberedText = (a, b) => {
  const aName = a.name;
  const bName = b.name;

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch && bNumberMatch && aName.replace(PATTERN_NUMBER, '') === bName.replace(PATTERN_NUMBER, '')) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return compareString(aName, bName);
};

const OrbitSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title, color, basic } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return (
    source.length > 0 && (
      <CollapsibleSection
        sectionKey={title}
        title={`${title} - (${source.length})`}
        forceOpen={things.length && searchText}
        showButton={!searchText}>
        {things.map((thing) =>
          basic ? (
            <Button
              key={thing.name}
              color={color}
              content={thing.name.replace(PATTERN_DESCRIPTOR, '')}
              onClick={() =>
                act('orbit', {
                  ref: thing.ref,
                })
              }
            />
          ) : (
            <OrbitedButton key={thing.name} color={color} thing={thing} job={thing.role_icon} antag={thing.antag_icon} />
          )
        )}
      </CollapsibleSection>
    )
  );
};

const OrbitedButton = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing, job, antag } = props;

  return (
    <Button
      color={color}
      style={{ 'line-height': '24px' }}
      onClick={() =>
        act('orbit', {
          ref: thing.ref,
        })
      }>
      {job && (
        <Box
          inline
          mr={0.5}
          ml={-0.5}
          style={{ 'transform': 'translateY(18.75%)' }}
          className={`job-icon16x16 job-icon-${job}`}
        />
      )}
      {antag && (
        <Box
          inline
          mr={0.5}
          ml={job ? -0.25 : -0.5}
          style={{ 'transform': 'translateY(18.75%)' }}
          className={`antag-hud16x16 antag-hud-${antag}`}
        />
      )}
      {thing.name}
      {thing.orbiters && (
        <Box inline ml={1}>
          {'('}
          {thing.orbiters} <Box as="img" src={resolveAsset('ghost.png')} opacity={0.7} />
          {')'}
        </Box>
      )}
    </Button>
  );
};

export const Orbit = (props, context) => {
  const { act, data } = useBackend(context);
  const { alive, antagonists, dead, ghosts, misc, npcs } = data;

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    if (collatedAntagonists[antagonist.antag] === undefined) {
      collatedAntagonists[antagonist.antag] = [];
    }
    collatedAntagonists[antagonist.antag].push(antagonist);
  }

  const sortedAntagonists = Object.entries(collatedAntagonists);
  sortedAntagonists.sort((a, b) => {
    return compareString(a[0], b[0]);
  });

  const orbitMostRelevant = (searchText) => {
    for (const source of [sortedAntagonists.map(([_, antags]) => antags), alive, ghosts, dead, npcs, misc]) {
      const member = source.filter(searchFor(searchText)).sort(compareNumberedText)[0];
      if (member !== undefined) {
        act('orbit', { ref: member.ref });
        break;
      }
    }
  };

  return (
    <Window theme="generic" width={350} height={700}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Icon name="search" mr={1} />
            </Flex.Item>
            <Flex.Item grow={1}>
              <Input
                placeholder="Search..."
                fluid
                value={searchText}
                onInput={(_, value) => setSearchText(value)}
                onEnter={(_, value) => orbitMostRelevant(value)}
              />
            </Flex.Item>
          </Flex>
        </Section>
        {antagonists.length > 0 && (
          <CollapsibleSection title="Ghost-Visible Antagonists" sectionKey="Ghost-Visible Antagonists" forceOpen={searchText}>
            {sortedAntagonists.map(([name, antags]) => (
              <OrbitSection key={name} title={name} source={antags} searchText={searchText} color="bad" />
            ))}
          </CollapsibleSection>
        )}

        <OrbitSection title="Alive" source={alive} searchText={searchText} color="good" />

        <OrbitSection title="Ghosts" source={ghosts} searchText={searchText} basic />

        <OrbitSection title="Dead" source={dead} searchText={searchText} basic />

        <OrbitSection title="NPCs" source={npcs} searchText={searchText} basic />

        <OrbitSection title="Misc" source={misc} searchText={searchText} basic />
      </Window.Content>
    </Window>
  );
};
