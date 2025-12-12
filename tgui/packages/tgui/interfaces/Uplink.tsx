import '../styles/interfaces/Uplink.scss';

import { capitalize, createSearch, decodeHtmlEntities } from 'common/string';

import { useBackend, useLocalState, useSharedState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import { NtosRadarMap, PointerZ, ZResult } from './NtosRadar';

const MAX_SEARCH_RESULTS = 25;

type ReputationLevel = {
  name: string;
  description: string;
  min_reputation?: number;
  max_reputation?: number;
};

type Item = {
  name: string;
  cost: number;
  desc: string;
  is_illegal: boolean;
  are_contents_illeal: boolean;
  reputation: number;
};

type Category = {
  name: string;
  items: Item[];
};

type ObjectiveData = {
  name: string;
  tasks: string[];
  track_x?: number;
  track_y?: number;
  track_z?: number;
  time?: number;
  details?: string;
  action?: string;
  rep_loss?: number;
  rep_gain?: number;
  reward?: number;
};

type UplinkData = {
  telecrystals: number;
  lockable: boolean;
  compactMode: boolean;
  reputation: number;
  time: number;
  pos_x?: number;
  pos_y?: number;
  pos_z?: number;
  objectives?: ObjectiveData[];
  categories: Category[];
};

const reputationLevels: { [reputation: number]: ReputationLevel } = {
  0: {
    name: 'Ex-Communicate',
    description:
      'A traitor to the cause, betraying their brothers to seek personal gain. Reaching this level will result in halted services and a termination order after 5 minutes.',
    min_reputation: undefined,
    max_reputation: 99,
  },
  100: {
    name: 'Blood Servant',
    description:
      'An operative with a reason to act, but without the will to fulfill their greater purpose.',
    min_reputation: 100,
    max_reputation: 199,
  },
  200: {
    name: 'Field Agent',
    description:
      'An operative acting on the ground, with access to some standard equipment that can be used to complete their mission.',
    min_reputation: 200,
    max_reputation: 399,
  },
  400: {
    name: 'Specialist',
    description:
      'An operative with specialized skills and knowledge, granted with additional resources and services for completing critical missions.',
    min_reputation: 400,
    max_reputation: 599,
  },
  600: {
    name: 'Operative',
    description:
      'An experienced operative who has demonstrated competence and effectiveness in completing various missions for the Syndicate.',
    min_reputation: 600,
    max_reputation: 799,
  },
  800: {
    name: 'Director',
    description:
      'A high-ranking official responsible for overseeing and coordinating operations with their team, ensuring the success of its objectives.',
    min_reputation: 800,
    max_reputation: 999,
  },
  1000: {
    name: 'Archon',
    description:
      'A high ranking and secretive authority, possessing unparalleled knowledge, influence, and control over operations and resources.',
    min_reputation: 1000,
    max_reputation: undefined,
  },
};

const GetLevel = (
  reputation,
  index_change = 0,
): ReputationLevel | undefined => {
  let currentLevel: ReputationLevel | undefined;
  let index = -1;

  // Find the highest reputation level that is less than the current reputation
  for (const level in reputationLevels) {
    if (level <= reputation || !currentLevel) {
      currentLevel = reputationLevels[level];
      index++;
    } else {
      break;
    }
  }
  // Adjust the index based on the change provided
  index += index_change;

  if (index < 0) {
    return {
      name: '',
      description: 'There are no lower levels within the Syndicate database.',
    };
  } else if (index >= Object.keys(reputationLevels).length) {
    return {
      name: '',
      description:
        'You are at the highest rank an agent can reach within the Syndicate.',
    };
  }

  // Get the reputation level at the adjusted index
  const levels = Object.keys(reputationLevels);
  const levelKey = levels[index];
  currentLevel = reputationLevels[levelKey];

  return currentLevel;
};

export const Uplink = (props) => {
  const { act, data } = useBackend<UplinkData>();
  const { telecrystals, reputation, lockable } = data;

  const [tab, setTab] = useSharedState('tab_id', 2);

  const currentLevel = GetLevel(reputation)?.name ?? 'unknown';

  return (
    <Window theme="syndicate" width={900} height={630}>
      <Window.Content scrollable minWidth="680px" minHeight="600px">
        <Tabs>
          <Tabs.Tab
            selected={tab === 2}
            onClick={() => {
              setTab(2);
            }}
          >
            Career Homepage
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 0}
            onClick={() => {
              setTab(0);
            }}
          >
            Agent Marketplace
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 1}
            onClick={() => {
              setTab(1);
            }}
          >
            Priority Directives
            {data.objectives &&
              data.objectives.filter((x) => x.reward).length > 0 && (
                <Tooltip content={'New directives are available.'}>
                  <Icon
                    ml={1}
                    name="bell"
                    color="yellow"
                    className="bell_ring"
                  />
                </Tooltip>
              )}
          </Tabs.Tab>
          <Tabs.Tab
            className={`reputation ${currentLevel
              ?.toLowerCase()
              .replace('-', '')
              .replace(/\s+/g, '-')}`}
          >
            {currentLevel ? currentLevel : 'Neutral Reputation'} ({reputation})
          </Tabs.Tab>
          <Box
            style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              padding: '0px 5px 0px 0px',
            }}
          >
            {!!lockable && (
              <Button icon="lock" content="Lock" onClick={() => act('lock')} />
            )}
          </Box>
        </Tabs>
        {tab === 0 ? (
          <GenericUplink currencyAmount={telecrystals} currencySymbol="TC" />
        ) : tab === 1 ? (
          <Directives />
        ) : (
          <HomePage />
        )}
      </Window.Content>
    </Window>
  );
};

const HomePage = (props) => {
  const { data } = useBackend<UplinkData>();
  const { reputation } = data;
  const [tab, setTab] = useSharedState('tab_id', 2);
  let previousLevel = GetLevel(reputation, -1);
  let currentLevel = GetLevel(reputation);
  let nextLevel = GetLevel(reputation, 1);
  return (
    <Flex direction="column" className="uplink_page">
      <Flex.Item height="100%">
        <div className="Home Section">
          <div className="HomeTitle">Welcome, Agent.</div>
          <div className="HomeTeam border_section">
            <div className="HomeIntro">
              <div>Welcome to the Syndicate universal uplink!</div>
              <div>
                The Syndicate is a coalition of companies and individuals
                seeking to reform inter-galactic law to improve the quality of
                life for all employees. Each organisation within the Syndicate
                has its own collection of goals, motivations and conflicts.
                Despite this, we have still managed to set aside our differences
                to resolve the greatest issue faced by all; Nanotrasen&apos;s
                monopoly over the individual.
              </div>
              <div>
                This uplink contains everything you need to start making a
                difference. Ready? Head to the
                <Box
                  ml={0.5}
                  mr={0.5}
                  inline
                  className="IntroLink"
                  onClick={() => {
                    setTab(1);
                  }}
                >
                  directives tab
                </Box>
                and find out what you can do to help, or explore our shared
                <Box
                  ml={0.5}
                  inline
                  className="IntroLink"
                  onClick={() => {
                    setTab(0);
                  }}
                >
                  goods-exchange tool
                </Box>
                .
              </div>
            </div>
          </div>
          <div className="HomeBottom">
            <div className="HomeRanks border_section">
              <RankCard
                name={previousLevel?.name ?? 'Unknown'}
                relation="Previous Rank"
                description={previousLevel?.description ?? ''}
                reputation={previousLevel?.min_reputation}
                reputation_delta={
                  previousLevel?.max_reputation &&
                  previousLevel.max_reputation - reputation
                }
                progression_colour="#6B1313"
              />
              <RankCard
                name={currentLevel?.name ?? 'Unknown'}
                relation="Current Rank"
                description={currentLevel?.description ?? ''}
                reputation={200}
                reputation_delta={0}
                current_rank
                progression_colour="#272727"
              />
              <RankCard
                name={nextLevel?.name ?? 'Unknown'}
                relation="Next Rank"
                description={nextLevel?.description}
                reputation={nextLevel?.min_reputation}
                reputation_delta={
                  nextLevel?.min_reputation &&
                  nextLevel.min_reputation - reputation
                }
                progression_colour="#134F12"
              />
            </div>
            <div className="HomeFaction border_section">
              Message from your organisation:
              <div className="TextFlash">
                All other Syndicate agents operating in this sector are to be
                considered hostile if they cannot reproduce the codewords.
              </div>
            </div>
          </div>
        </div>
      </Flex.Item>
    </Flex>
  );
};

const RankCard = (props, contxt) => {
  const {
    relation,
    name,
    description,
    reputation,
    reputation_delta,
    current_rank = false,
    progression_colour = '#6B1313',
  } = props;
  return (
    <div className="RankCard">
      <div
        className={
          current_rank ? 'RankCardMain RankCardHighlight' : 'RankCardMain'
        }
      >
        <div className="RankCardTitle">
          {relation}
          <div className="RankCardName">{name}</div>
        </div>
        {description}
      </div>
      {!current_rank && !!reputation_delta && (
        <div
          className="RankCardProgression"
          style={{
            background:
              'linear-gradient(0deg, #999 -300%, ' +
              progression_colour +
              ' 100%)',
          }}
        >
          {reputation_delta > 0
            ? 'Gain ' + reputation_delta + ' reputation to reach promotion'
            : 'Demotion if ' + -reputation_delta + ' reputation is lost'}
        </div>
      )}
    </div>
  );
};

const Directives = (props) => {
  const [selected, setSelected] = useLocalState('sel_obj', 0);
  const { act, data } = useBackend<UplinkData>();
  const { pos_x, pos_y, pos_z = 0, time, objectives } = data;
  const selectedObjective =
    objectives && (objectives[selected] || objectives[0]);
  const { track_x, track_y, track_z, action } = selectedObjective || {};
  const dx = (track_x ?? 0) - (pos_x ?? 0);
  const dy = (track_y ?? 0) - (pos_y ?? 0);
  const angle = (360 / (Math.PI * 2)) * Math.atan2(dx, dy);
  if (selectedObjective === null) {
    return <Box>No associated objectives.</Box>;
  }
  return (
    <Flex direction="column" className="uplink_page">
      <Flex.Item>
        <Section title="Directives Database">
          <Flex
            style={{
              overflowY: 'scroll',
            }}
          >
            {objectives &&
              objectives.map((objective, index) => (
                <ObjectiveCard
                  key={objective}
                  selected={selected === index}
                  onClick={() => {
                    setSelected(index);
                  }}
                  objective_info={{
                    name: objective.name,
                    reward: objective.reward || 0,
                    time_left: objective.time
                      ? (objective.time - time) * 0.1
                      : null,
                    rep_gain: objective.rep_gain || null,
                    rep_loss: objective.rep_loss || null,
                  }}
                />
              ))}
          </Flex>
        </Section>
      </Flex.Item>
      <Flex.Item grow={1}>
        <div className="directive_container">
          <div className="directive_radar">
            <NtosRadarMap
              sig_err="The target of this objective cannot be tracked."
              displayError={!track_x || !track_y || !pos_x || !pos_y}
              rightAlign
              target={
                !track_x
                  ? undefined
                  : {
                      dist:
                        track_x && track_y
                          ? Math.abs(pos_x! - track_x!) +
                            Math.abs(pos_y! - track_y!)
                          : 0,
                      gpsx: track_x!,
                      gpsy: track_y!,
                      locy: pos_y! - track_y! + 24,
                      locx: track_x - pos_x! + 24,
                      gpsz: track_z ?? 0,
                      use_rotate: track_y
                        ? Math.abs(pos_x! - track_x) +
                            Math.abs(pos_y! - track_y) >
                          26
                        : false,
                      rotate_angle: angle,
                      arrowstyle: 'ntosradarpointer.png',
                      pointer_z:
                        track_z && pos_z > track_z
                          ? PointerZ.CaretUp
                          : track_z && pos_z < track_z
                            ? PointerZ.CaretDown
                            : undefined,
                      locz_string: '',
                      pin_grand_z_result:
                        pos_z === track_z
                          ? ZResult.Z_RESULT_SAME_Z
                          : ZResult.Z_RESULT_TOO_FAR,
                      color: 'red',
                    }
              }
            />
          </div>
          <div className="directive_info">
            <div className="directive_section Section">
              <div className="Section__title">
                <span className="Section__titleText">Objective Details</span>
              </div>
              <div className="Section__rest">
                <div className="Section__content">
                  <Box mb={1} underline bold>
                    Tasks
                  </Box>
                  {selectedObjective?.tasks.map((task) => (
                    <Box key={task}>
                      <Icon
                        inline
                        name="square-o"
                        mr={1}
                        className="directive_check"
                      />
                      {task}
                    </Box>
                  ))}
                  {(selectedObjective?.rep_gain ||
                    selectedObjective?.rep_loss) && (
                    <>
                      <Box mt={3} mb={1} underline bold>
                        Reputation Details
                      </Box>
                      <Box>
                        This mission will affect your reputation level.
                        <br />
                        <ul>
                          <li>
                            Success will result in gaining{' '}
                            {selectedObjective?.rep_gain} reputation.
                          </li>
                          <li>
                            Failure will result in losing{' '}
                            {selectedObjective?.rep_loss} reputation.
                          </li>
                        </ul>
                      </Box>
                    </>
                  )}
                  <Box mt={3} mb={1} underline bold>
                    Additional Details
                  </Box>
                  <Box>
                    {selectedObjective?.details ||
                      'This mission is part of your assignment and must be\
                    completed. No additional reward will be provided outside of the\
                    terms that have been defined within your contract of employment.'}
                  </Box>
                </div>
              </div>
              <div className="directive_prize">
                <div className="directive_prize_info">
                  <Flex.Item>
                    <Icon name={selectedObjective?.reward ? 'gem' : 'slash'} />
                  </Flex.Item>
                  <Flex.Item grow pl={2}>
                    <Box bold>
                      {selectedObjective?.reward
                        ? selectedObjective?.reward + ' Telecrystals'
                        : 'No reward'}
                    </Box>
                    {selectedObjective?.rep_gain && (
                      <Box bold>{selectedObjective?.rep_gain} Reputation</Box>
                    )}
                  </Flex.Item>
                </div>
                <Flex.Item
                  grow
                  height="100%"
                  align="flex-end"
                  textAlign="right"
                >
                  <Button
                    height="100%"
                    fontSize={2}
                    content={action ? action : 'Collect Reward'}
                    disabled={!action}
                    icon="hands-helping"
                    onClick={() => act('directive_action')}
                  />
                </Flex.Item>
              </div>
            </div>
          </div>
        </div>
      </Flex.Item>
    </Flex>
  );
};

const ObjectiveCard = (props) => {
  const {
    objective_info = {
      name: 'Assassination',
      reward: 0,
      time_left: null,
      rep_gain: null,
      rep_loss: null,
    },
    selected = 0,
    onClick,
  } = props;
  const { name, reward, time_left, rep_gain, rep_loss } = objective_info;
  return (
    <Flex.Item
      className={'objective_card ' + (selected && 'selected')}
      onClick={onClick}
    >
      <Stack vertical>
        <Stack.Item bold>{capitalize(name)}</Stack.Item>
        <Stack.Divider />
      </Stack>
      <Box
        className="reward_overlay"
        align="flex-end"
        color={reward === 0 ? 'orange' : 'good'}
      >
        <Tooltip
          content={
            (rep_gain || rep_loss) &&
            'Failure to complete this directive will result in a loss of reputation.'
          }
        >
          {(rep_gain || rep_loss) && (
            <Box>
              {rep_loss && (
                <>
                  <Box color="bad" inline>
                    -{rep_loss}
                  </Box>
                  /
                </>
              )}
              <Box color="good" inline>
                +{rep_gain}
              </Box>{' '}
              Reputation
            </Box>
          )}
          {reward === 0 ? 'Assignment' : reward + ' TC Reward'}
        </Tooltip>
      </Box>
      <Box className="time_limit">
        {time_left === null || time_left > 60 * 60 * 10
          ? '--:--'
          : '00:' +
            String(Math.floor(time_left / 60)).padStart(2, '0') +
            ':' +
            String(Math.floor(time_left) % 60).padStart(2, '0')}
      </Box>
    </Flex.Item>
  );
};

export const GenericUplink = (props) => {
  const { currencyAmount = 0, currencySymbol = 'cr' } = props;
  const { act, data } = useBackend<UplinkData>();
  const { compactMode, categories = [], reputation } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [selectedCategory, setSelectedCategory] = useLocalState(
    'category',
    categories[0]?.name,
  );
  const testSearch = createSearch<Item>(searchText, (item) => {
    return item.name + item.desc;
  });
  const items =
    (searchText.length > 0 &&
      // Flatten all categories and apply search to it
      categories
        .flatMap((category) => category.items || [])
        .filter(testSearch)
        .filter((item, i) => i < MAX_SEARCH_RESULTS)) ||
    // Select a category and show all items in it
    categories.find((category) => category.name === selectedCategory)?.items ||
    // If none of that results in a list, return an empty list
    [];
  return (
    <Section
      title={
        <Box inline color={currencyAmount > 0 ? 'good' : 'bad'}>
          {formatMoney(currencyAmount)} {currencySymbol}
        </Box>
      }
      buttons={
        <>
          Search
          <Input
            value={searchText}
            autoFocus
            onInput={(e, value) => setSearchText(value)}
            mx={1}
          />
          <Button
            icon={compactMode ? 'list' : 'info'}
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => act('compact_toggle')}
          />
        </>
      }
    >
      <Flex>
        {searchText.length === 0 && (
          <Flex.Item>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}
                >
                  {category.name} ({category.items?.length || 0})
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
        )}
        <Flex.Item grow mx={2.5} basis={0}>
          {items.length === 0 && (
            <NoticeBox>
              {searchText.length === 0
                ? 'No items in this category.'
                : 'No results found.'}
            </NoticeBox>
          )}
          <ItemList
            reputation={reputation}
            compactMode={searchText.length > 0 || compactMode}
            currencyAmount={currencyAmount}
            currencySymbol={currencySymbol}
            items={items}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const ItemList = (props) => {
  const { reputation, compactMode, currencyAmount, currencySymbol } = props;
  const { act } = useBackend<UplinkData>();
  const [hoveredItem, setHoveredItem] = useLocalState<Item | undefined>(
    'hoveredItem',
    undefined,
  );
  const hoveredCost = (hoveredItem && hoveredItem.cost) || 0;
  // Append extra hover data to items
  const items = props.items.map((item) => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled =
      reputation < item.reputation ||
      currencyAmount < item.cost ||
      disabledDueToHovered;
    return {
      ...item,
      disabled,
    };
  });
  if (compactMode) {
    return (
      <Table>
        {items.map((item) => (
          <Table.Row key={item.name} className="candystripe">
            <Table.Cell bold>{decodeHtmlEntities(item.name)}</Table.Cell>
            {item.reputation ? (
              <Table.Cell collapsing textAlign="right">
                <Box color={reputation >= item.reputation ? 'green' : 'red'}>
                  {item.reputation} reputation
                </Box>
              </Table.Cell>
            ) : (
              <Table.Cell />
            )}
            {currencyAmount < item.cost ? (
              <Table.Cell collapsing textAlign="right">
                <Box color="red">Insufficient Funds</Box>
              </Table.Cell>
            ) : (
              <Table.Cell />
            )}
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={formatMoney(item.cost) + ' ' + currencySymbol}
                disabled={item.disabled}
                tooltip={item.desc}
                tooltipPosition="left"
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem(undefined)}
                onClick={() =>
                  act('buy', {
                    name: item.name,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    );
  }
  return items.map((item) => (
    <Section
      key={item.name}
      title={item.name}
      level={2}
      buttons={
        <Table>
          {item.reputation ? (
            <Table.Cell textAlign="right">
              <Box color={reputation >= item.reputation ? 'green' : 'red'}>
                {item.reputation} reputation
              </Box>
            </Table.Cell>
          ) : (
            ''
          )}
          {item.cost > currencyAmount ? (
            <Table.Cell collapsing={!!item.reputation} textAlign="right">
              <Box color="red">Insufficient Funds</Box>
            </Table.Cell>
          ) : (
            ''
          )}
          <Table.Cell collapsing textAlign="right">
            <Button
              content={item.cost + ' ' + currencySymbol}
              disabled={item.disabled}
              onmouseover={() => setHoveredItem(item)}
              onmouseout={() => setHoveredItem(undefined)}
              onClick={() =>
                act('buy', {
                  name: item.name,
                })
              }
            />
          </Table.Cell>
        </Table>
      }
    >
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
