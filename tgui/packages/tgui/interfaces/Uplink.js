import { capitalize, createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState, useSharedState } from '../backend';
import { Stack, Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Grid, Divider, Icon, Tooltip } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import '../styles/interfaces/Uplink.scss';
import { NtosRadarMap } from './NtosRadar';
import { Color } from 'common/color';
import { classes } from 'common/react';

const MAX_SEARCH_RESULTS = 25;

const reputationLevels = {
  0: {
    name: "Ex-Communicate",
    description: "A traitor to the cause, betraying their brothers to seek personal gain. Reaching this level will result in halted services and a termination order after 5 minutes.",
    min_reputation: null,
    max_reputation: 99,
  },
  100: {
    name: "Blood Servant",
    description: "An operative with a reason to act, but without the will to fulfill their greater purpose.",
    min_reputation: 100,
    max_reputation: 199,
  },
  200: {
    name: "Field Agent",
    description: "An operative acting on the ground, with access to some standard equipment that can be used to complete their mission.",
    min_reputation: 200,
    max_reputation: 399,
  },
  400: {
    name: "Specialist",
    description: "An operative with specialized skills and knowledge, granted with additional resources and services for completing critical missions.",
    min_reputation: 400,
    max_reputation: 599,
  },
  600: {
    name: "Operative",
    description: "An experienced operative who has demonstrated competence and effectiveness in completing various missions for the Syndicate.",
    min_reputation: 600,
    max_reputation: 799,
  },
  800: {
    name: "Director",
    description: "A high-ranking official responsible for overseeing and coordinating operations with their team, ensuring the success of its objectives.",
    min_reputation: 800,
    max_reputation: 999,
  },
  1000: {
    name: "Archon",
    description: "A high ranking and secretive authority, possessing unparalleled knowledge, influence, and control over operations and resources.",
    min_reputation: 1000,
    max_reputation: null,
  },
};

const GetLevel = (reputation, index_change = 0) => {
  let currentLevel = null;
  let index = -1;

  // Find the highest reputation level that is less than the current reputation
  for (const level in reputationLevels) {
    if (level <= reputation || currentLevel === null) {
      currentLevel = reputationLevels[level];
      index ++;
    } else {
      break;
    }
  }
  // Adjust the index based on the change provided
  index += index_change;

  if (index < 0)
  {
    return {
      name: "",
      description: "There are no lower levels within the Syndicate database.",
    };
  }
  else if (index >= Object.keys(reputationLevels).length)
  {
    return {
      name: "",
      description: "You are at the highest rank an agent can reach within the Syndicate.",
    };
  }

  // Get the reputation level at the adjusted index
  const levels = Object.keys(reputationLevels);
  const levelKey = levels[index];
  currentLevel = reputationLevels[levelKey];

  return currentLevel;
};

export const Uplink = (props, context) => {
  const { data } = useBackend(context);
  const { telecrystals, reputation } = data;

  const [tab, setTab] = useSharedState(context, 'tab_id', 2);

  let currentLevel = GetLevel(reputation).name;

  return (
    <Window theme="syndicate" width={900} height={600}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === 2}
            onClick={() => {
              setTab(2);
            }}>
            Career Homepage
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 0}
            onClick={() => {
              setTab(0);
            }}>
            Agent Marketplace
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 1}
            onClick={() => {
              setTab(1);
            }}>
            Priority Directives
            <Tooltip content={'New directives are available.'}>
              <Icon ml={1} name="bell" color="yellow" className="bell_ring" />
            </Tooltip>
          </Tabs.Tab>
          <Tabs.Tab className={`reputation ${currentLevel?.toLowerCase().replace('-', '').replace(/\s+/g, '-')}`}>
            {currentLevel ? currentLevel : "Neutral Reputation"} ({reputation})
          </Tabs.Tab>
        </Tabs>
        {tab === 0
          ? <GenericUplink currencyAmount={telecrystals} currencySymbol="TC" />
          : tab === 1
            ? <Directives />
            : <HomePage />}
      </Window.Content>
    </Window>
  );
};

const HomePage = (props, context) => {
  const { data } = useBackend(context);
  const { reputation } = data;
  let previousLevel = GetLevel(reputation, -1);
  let currentLevel = GetLevel(reputation);
  let nextLevel = GetLevel(reputation, 1);
  return (
    <Flex direction="column" className="uplink_page">
      <Flex.Item height="100%">
        <div className="Home Section">
          <div className="HomeLeft">
            <div className="HomeTitle">
              Welcome, Agent.
            </div>
            <div className="HomeRanks">
              <RankCard
                name={previousLevel.name}
                relation="Previous Rank"
                description={previousLevel.description}
                reputation={previousLevel.min_reputation}
                reputation_delta={previousLevel.max_reputation - reputation}
                progression_colour="#6B1313"
                />
              <RankCard
                name={currentLevel.name}
                relation="Current Rank"
                description={currentLevel.description}
                reputation={200}
                reputation_delta={0}
                current_rank
                progression_colour="#272727"
                />
              <RankCard
                name={nextLevel.name}
                relation="Next Rank"
                description={nextLevel.description}
                reputation={nextLevel.min_reputation}
                reputation_delta={nextLevel.min_reputation - reputation}
                progression_colour="#134F12"
                />
            </div>
          </div>
          <div className="HomeRight">
            Current Reputation
            <div className="HomeButton">
              200 Reputation
            </div>
            Uplink Services
            <div className="HomeButton">
              Shop Now
            </div>
            Special Directives
            <div className="HomeButton">
              None Available
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
    progression_colour = "#6B1313",
  } = props;
  return (
    <div className="RankCard">
      <div className={current_rank ? "RankCardMain RankCardHighlight" : "RankCardMain"}>
        <div className="RankCardTitle">
          {relation}
          <div className="RankCardName">
            {name}
          </div>
        </div>
        {description}
      </div>
      {!current_rank && !!reputation_delta && (
        <div className="RankCardProgression" style={{
          background: "linear-gradient(0deg, #999 -300%, " + progression_colour + " 100%)",
        }}>
          {reputation_delta > 0 ? ("Gain " + reputation_delta + " reputation to reach promotion") : ("Demotion if " + -reputation_delta + " reputation is lost")}
        </div>
      )}

    </div>
  );
};

const Directives = (props, context) => {
  const [selected, setSelected] = useLocalState(context, 'sel_obj', 0);
  const { act, data } = useBackend(context);
  const { pos_x = 0, pos_y = 0, pos_z = 0, time, objectives = [] } = data.objectives;
  const selectedObjective = objectives[selected] || objectives[0];
  const { track_x, track_y, track_z, action } = selectedObjective || {};
  const dx = track_x - pos_x;
  const dy = track_y - pos_y;
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
            }}>
            {objectives.map((objective, index) => (
              <ObjectiveCard
                key={objective}
                selected={selected === index}
                onClick={() => {
                  setSelected(index);
                }}
                objective_info={{
                  name: objective.name,
                  reward: objective.reward || 0,
                  time_left: objective.time ? (objective.time - time) * 0.1 : null,
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
              selected={!track_x}
              rightAlign
              target={
                !track_x
                  ? {}
                  : {
                    dist: Math.abs(pos_x - track_x) + Math.abs(pos_y - track_y),
                    gpsx: track_x,
                    gpsy: track_y,
                    locy: pos_y - track_y + 24,
                    locx: track_x - pos_x + 24,
                    gpsz: track_z,
                    use_rotate: Math.abs(pos_x - track_x) + Math.abs(pos_y - track_y) > 26,
                    rotate_angle: angle,
                    arrowstyle: 'ntosradarpointer.png',
                    pointer_z: pos_z > track_z ? 'caret-up' : pos_z < track_z ? 'caret-down' : null,
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
                      <Icon inline name="square-o" mr={1} className="directive_check" />
                      {task}
                    </Box>
                  ))}
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
                    <Icon name={action ? 'gem' : 'slash'} />
                  </Flex.Item>
                  <Flex.Item grow pl={2}>
                    <Box bold>{selectedObjective?.reward ? selectedObjective?.reward + ' Telecrystals' : 'No reward'}</Box>
                  </Flex.Item>
                </div>
                <Flex.Item grow height="100%" align="flex-end" textAlign="right">
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

const ObjectiveCard = (props, context) => {
  const {
    objective_info = {
      name: 'Assassination',
      reward: 0,
      time_left: null,
    },
    selected = 0,
    onClick,
  } = props;
  const { name, reward, time_left } = objective_info;
  return (
    <Flex.Item className={'objective_card ' + (selected && 'selected')} onClick={onClick}>
      <Stack vertical>
        <Stack.Item bold>{capitalize(name)}</Stack.Item>
        <Stack.Divider />
      </Stack>
      <Box className="reward_overlay" align="flex-end" color={reward === 0 ? 'orange' : 'good'}>
        {reward === 0 ? 'Assignment' : reward + ' TC Reward'}
      </Box>
      <Box className="time_limit">
        {time_left === null
          ? '--:--'
          : '00:' +
          String(Math.floor(time_left / 60)).padStart(2, '0') +
          ':' +
          String(Math.floor(time_left) % 60).padStart(2, '0')}
      </Box>
    </Flex.Item>
  );
};

export const GenericUplink = (props, context) => {
  const { currencyAmount = 0, currencySymbol = 'cr' } = props;
  const { act, data } = useBackend(context);
  const { compactMode, lockable, categories = [], reputation } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [selectedCategory, setSelectedCategory] = useLocalState(context, 'category', categories[0]?.name);
  const testSearch = createSearch(searchText, (item) => {
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
          <Input value={searchText} autoFocus onInput={(e, value) => setSearchText(value)} mx={1} />
          <Button
            icon={compactMode ? 'list' : 'info'}
            content={compactMode ? 'Compact' : 'Detailed'}
            onClick={() => act('compact_toggle')}
          />
          {!!lockable && <Button icon="lock" content="Lock" onClick={() => act('lock')} />}
        </>
      }>
      <Flex>
        {searchText.length === 0 && (
          <Flex.Item>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}>
                  {category.name} ({category.items?.length || 0})
                </Tabs.Tab>
              ))}
            </Tabs>
          </Flex.Item>
        )}
        <Flex.Item grow mx={2.5} basis={0}>
          {items.length === 0 && (
            <NoticeBox>{searchText.length === 0 ? 'No items in this category.' : 'No results found.'}</NoticeBox>
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

const ItemList = (props, context) => {
  const { reputation, compactMode, currencyAmount, currencySymbol } = props;
  const { act } = useBackend(context);
  const [hoveredItem, setHoveredItem] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = (hoveredItem && hoveredItem.cost) || 0;
  // Append extra hover data to items
  const items = props.items.map((item) => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = reputation < item.reputation || currencyAmount < item.cost || disabledDueToHovered;
    return {
      ...item,
      disabled,
    };
  });
  const GetTooltipMessage = (entry_name, is_illegal, are_contents_illegal) => {
    if (is_illegal) {
      return (
        <Tooltip content="This product is powered by our latest technology. Please do not let Nanotrasen R&D steal our confidential designs.">
          <Box inline position="relative" mr={1}>
            {entry_name}
          </Box>
        </Tooltip>
      );
    } else if (are_contents_illegal) {
      return (
        <Tooltip content="The catalogue information is labeled as the product is implemented with our technology, but this may not be correct. If you're looking for a product with our technology, be careful of purchasing this.">
          <Box inline position="relative" mr={1}>
            {entry_name}
          </Box>
        </Tooltip>
      );
    } else {
      return (
        <Tooltip content="This product is not implemented with our technology.">
          <Box inline position="relative" mr={1}>
            {entry_name}
          </Box>
        </Tooltip>
      );
    }
  };
  if (compactMode) {
    return (
      <Table>
        {items.map((item) => (
          <Table.Row key={item.name} className="candystripe">
            <Table.Cell bold>{decodeHtmlEntities(item.name)}</Table.Cell>
            {item.reputation ? (
              <Table.Cell collapsing textAlign="right">
                <Box color={reputation >= item.reputation ? "green" : "red"}>
                  {item.reputation} reputation
                </Box>
              </Table.Cell>
            ) : <Table.Cell />}
            {currencyAmount < item.cost ? (
              <Table.Cell collapsing textAlign="right">
                <Box color="red">
                  Insufficient Funds
                </Box>
              </Table.Cell>
            ) : <Table.Cell />}
            <Table.Cell collapsing textAlign="right">
              <Button
                fluid
                content={formatMoney(item.cost) + ' ' + currencySymbol}
                disabled={item.disabled}
                tooltip={item.desc}
                tooltipPosition="left"
                onmouseover={() => setHoveredItem(item)}
                onmouseout={() => setHoveredItem({})}
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
      title={GetTooltipMessage(item.name, item.is_illegal, item.are_contents_illegal)}
      level={2}
      buttons={
        <Table>
        {item.reputation ? (
          <Table.Cell textAlign="right">
            <Box color={reputation >= item.reputation ? "green" : "red"}>
              {item.reputation} reputation
            </Box>
          </Table.Cell>
        ) : ""}
          {item.cost > currencyAmount ? (
            <Table.Cell collapsing={!!item.reputation} textAlign="right">
              <Box color="red">
                Insufficient Funds
              </Box>
            </Table.Cell>
          ) : ""}
          <Table.Cell collapsing textAlign="right">
            <Button
              content={item.cost + ' ' + currencySymbol}
              disabled={item.disabled}
              onmouseover={() => setHoveredItem(item)}
              onmouseout={() => setHoveredItem({})}
              onClick={() =>
                act('buy', {
                  name: item.name,
                })
              }
            />
          </Table.Cell>
        </Table>
      }>
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
