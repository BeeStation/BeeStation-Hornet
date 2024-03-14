import { capitalize, createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Stack, Box, Button, Flex, Input, Section, Table, Tabs, NoticeBox, Grid, Divider, Icon, Tooltip } from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';
import '../styles/interfaces/Uplink.scss';
import { NtosRadarMap } from './NtosRadar';

const MAX_SEARCH_RESULTS = 25;

export const Uplink = (props, context) => {
  const { data } = useBackend(context);
  const { telecrystals } = data;

  const [tab, setTab] = useLocalState(context, 'tab_id', 0);

  return (
    <Window theme="syndicate" width={900} height={600}>
      <Window.Content scrollable>
        <Tabs>
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
        </Tabs>
        {tab === 0 ? <GenericUplink currencyAmount={telecrystals} currencySymbol="TC" /> : tab === 1 && <Directives />}
      </Window.Content>
    </Window>
  );
};

const Directives = (props, context) => {
  const [selected, setSelected] = useLocalState(context, 'sel_obj', 0);
  const { act, data } = useBackend(context);
  const { pos_x = 0, pos_y = 0, pos_z = 0, time, objectives = [] } = data.objectives;
  const selectedObjective = objectives[selected] || objectives[0];
  const { track_x, track_y, track_z } = selectedObjective || {};
  const dx = track_x - pos_x;
  const dy = track_y - pos_y;
  const angle = (360 / (Math.PI * 2)) * Math.atan2(dx, dy);
  return (
    <Flex direction="column" className="directives">
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
                  {selectedObjective.tasks.map((task) => (
                    <Box key={task}>
                      <Icon inline name="square-o" mr={1} className="directive_check" />
                      {task}
                    </Box>
                  ))}
                  <Box mt={3} mb={1} underline bold>
                    Additional Details
                  </Box>
                  <Box>
                    {selectedObjective.details ||
                      'This mission is part of your assignment and must be\
                    completed. No additional reward will be provided outside of the\
                    terms that have been defined within your contract of employment.'}
                  </Box>
                </div>
              </div>
              <div className="directive_prize">
                <div className="directive_prize_info">
                  <Flex.Item>
                    <Icon name="slash" />
                  </Flex.Item>
                  <Flex.Item grow>
                    <Box bold>No Reward</Box>
                  </Flex.Item>
                </div>
                <Flex.Item grow height="100%" align="flex-end" textAlign="right">
                  <Button height="100%" fontSize={2} content="Collect Reward" disabled icon="hands-helping" />
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
  const { compactMode, lockable, categories = [] } = data;
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
  const { compactMode, currencyAmount, currencySymbol } = props;
  const { act } = useBackend(context);
  const [hoveredItem, setHoveredItem] = useLocalState(context, 'hoveredItem', {});
  const hoveredCost = (hoveredItem && hoveredItem.cost) || 0;
  // Append extra hover data to items
  const items = props.items.map((item) => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = currencyAmount - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    const disabled = currencyAmount < item.cost || disabledDueToHovered;
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
      title={item.name}
      level={2}
      buttons={
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
      }>
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
