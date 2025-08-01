import { createSearch, decodeHtmlEntities } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Input,
  NoticeBox,
  Section,
  Table,
  Tabs,
  Tooltip,
} from '../components';
import { formatMoney } from '../format';
import { Window } from '../layouts';

const MAX_SEARCH_RESULTS = 25;

export const Uplink = (props) => {
  const { data } = useBackend();
  const { telecrystals } = data;
  return (
    <Window theme="syndicate" width={900} height={600}>
      <Window.Content scrollable>
        <GenericUplink currencyAmount={telecrystals} currencySymbol="TC" />
      </Window.Content>
    </Window>
  );
};

export const GenericUplink = (props) => {
  const { currencyAmount = 0, currencySymbol = 'cr' } = props;
  const { act, data } = useBackend();
  const { compactMode, lockable, categories = [] } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [selectedCategory, setSelectedCategory] = useLocalState(
    'category',
    categories[0]?.name,
  );
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
          {!!lockable && (
            <Button icon="lock" content="Lock" onClick={() => act('lock')} />
          )}
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
  const { compactMode, currencyAmount, currencySymbol } = props;
  const { act } = useBackend();
  const [hoveredItem, setHoveredItem] = useLocalState('hoveredItem', {});
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
      title={GetTooltipMessage(
        item.name,
        item.is_illegal,
        item.are_contents_illegal,
      )}
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
      }
    >
      {decodeHtmlEntities(item.desc)}
    </Section>
  ));
};
