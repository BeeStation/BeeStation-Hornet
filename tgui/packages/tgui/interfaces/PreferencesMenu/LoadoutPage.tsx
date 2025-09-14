import { createSearch } from 'common/string';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Flex,
  Icon,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import { LoadoutGear, PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const isPurchased = (purchased_gear: string[], gear: LoadoutGear) =>
  purchased_gear.includes(gear.id) && !gear.multi_purchase;

export const LoadoutPage = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    purchased_gear = [],
    metacurrency_balance = 0,
    is_donator = false,
  } = data;

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading loadout data...</Box>;
        }
        const { categories = [], metacurrency_name } = serverData.loadout;
        const [selectedCategory, setSelectedCategory] = useLocalState(
          'category',
          categories[0].name,
        );
        let [searchText, setSearchText] = useLocalState('loadout_search', '');
        let search = createSearch(searchText, (gear: LoadoutGear) => {
          return (
            gear.display_name +
            ' ' +
            gear.skirt_display_name +
            ' ' +
            gear.allowed_roles?.join(' ')
          );
        });

        let selectedCategoryObject = categories.filter(
          (c) => c.name === selectedCategory,
        )[0];
        let currency_text =
          metacurrency_balance.toLocaleString() + ' ' + metacurrency_name + 's';
        const showRoles =
          !selectedCategoryObject ||
          selectedCategoryObject.gear.filter((g) => g.allowed_roles?.length)
            .length > 0;

        return (
          <Stack height="100%">
            <Stack.Item style={{ maxHeight: '640px' }}>
              <Flex
                width="219px"
                mb={1}
                p={1}
                fontSize="22px"
                style={{ alignItems: 'center' }}
                className="section-background"
              >
                <Flex.Item>
                  <Button
                    icon="undo"
                    tooltip="Rotate"
                    tooltipPosition="top"
                    onClick={() => act('rotate')}
                  />
                </Flex.Item>
                <Flex.Item
                  grow
                  textAlign="center"
                  fontSize={
                    Math.max(Math.min(19, 34 - currency_text.length), 13) + 'px'
                  }
                >
                  {currency_text}
                </Flex.Item>
              </Flex>
              <CharacterPreview
                height="588px"
                id={data.character_preview_view}
              />
            </Stack.Item>
            <Stack.Item grow height="640px">
              <Flex direction="column" height="100%">
                <Flex.Item mb={1}>
                  <Section fill>
                    <Icon mr={1} name="search" />
                    <Input
                      width="500px"
                      placeholder="Search items"
                      value={searchText}
                      onInput={(_, value) => setSearchText(value)}
                    />
                  </Section>
                </Flex.Item>
                {!searchText?.length && (
                  <Flex.Item>
                    <Tabs pt={0.1}>
                      {categories
                        .filter((c) => c.name !== 'Donator' || is_donator)
                        .map((category) => (
                          <Tabs.Tab
                            key={category.name}
                            textAlign="center"
                            selected={selectedCategory === category.name}
                            onClick={() => setSelectedCategory(category.name)}
                          >
                            {category.name}
                          </Tabs.Tab>
                        ))}
                      <Tabs.Tab
                        textAlign="center"
                        selected={selectedCategory === 'Purchased'}
                        onClick={() => setSelectedCategory('Purchased')}
                      >
                        Purchased
                      </Tabs.Tab>
                    </Tabs>
                  </Flex.Item>
                )}
                <Flex.Item grow basis="content" height="100%">
                  <Box
                    width="100%"
                    height="100%"
                    className="section-background"
                    style={{ padding: '0.66em 0.5em', overflowY: 'scroll' }}
                  >
                    <Table>
                      <Table.Row header>
                        <Table.Cell collapsing />
                        <Table.Cell>Name</Table.Cell>
                        {showRoles || searchText.length ? (
                          <Table.Cell style={{ width: '15rem' }}>
                            Roles
                          </Table.Cell>
                        ) : null}
                        {selectedCategory !== 'Donator' && (
                          <Table.Cell collapsing textAlign="center">
                            Cost
                          </Table.Cell>
                        )}
                        <Table.Cell style={{ minWidth: '7rem' }} collapsing />
                      </Table.Row>
                      {!searchText?.length && selectedCategoryObject
                        ? selectedCategoryObject.gear.map((gear) => (
                            <GearEntry
                              key={gear.id}
                              gear={gear}
                              selectedCategory={selectedCategory}
                              metacurrency_name={metacurrency_name}
                              showRoles={showRoles}
                            />
                          ))
                        : null}
                      {searchText.length || selectedCategory === 'Purchased'
                        ? categories
                            .flatMap((c) => c.gear)
                            .filter((gear) =>
                              searchText.length
                                ? search(gear)
                                : isPurchased(purchased_gear, gear),
                            )
                            .map((gear) => (
                              <GearEntry
                                key={gear.id}
                                gear={gear}
                                selectedCategory={selectedCategory}
                                metacurrency_name={metacurrency_name}
                                showRoles
                              />
                            ))
                        : null}
                    </Table>
                  </Box>
                </Flex.Item>
              </Flex>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
};

const GearEntry = (props: {
  gear: LoadoutGear;
  metacurrency_name: string;
  selectedCategory: string;
  showRoles?: boolean;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    equipped_gear = [],
    purchased_gear = [],
    metacurrency_balance,
    character_preferences,
    is_donator = false,
  } = data;
  const { gear, metacurrency_name, selectedCategory, showRoles = true } = props;
  const jumpsuit_style = character_preferences.clothing.jumpsuit_style;

  return (
    <Table.Row className="candystripe" key={gear.id}>
      <Table.Cell m={0} p={0}>
        <Box
          inline
          className={`preferences_loadout32x32 loadout_gear___${gear.id}${
            jumpsuit_style === 'Jumpskirt' && gear.skirt_display_name
              ? '_skirt'
              : ''
          }`}
          style={{
            verticalAlign: 'middle',
            horizontalAlign: 'middle',
          }}
        />
      </Table.Cell>
      <Table.Cell
        style={{
          maxWidth: '1px',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
          overflow: 'hidden',
          verticalAlign: 'middle',
        }}
      >
        {gear.description || gear.skirt_description ? (
          <Tooltip
            content={
              jumpsuit_style === 'Jumpskirt' && gear.skirt_description
                ? gear.skirt_description
                : gear.description
            }
          >
            <Box
              inline
              style={
                gear.description || gear.skirt_description
                  ? { borderBottom: '1px dotted #909090', paddingBottom: '1px' }
                  : undefined
              }
            >
              {jumpsuit_style === 'Jumpskirt' && gear.skirt_display_name
                ? gear.skirt_display_name
                : gear.display_name}
            </Box>
          </Tooltip>
        ) : (
          <Box inline>
            {jumpsuit_style === 'Jumpskirt' && gear.skirt_display_name
              ? gear.skirt_display_name
              : gear.display_name}
          </Box>
        )}
      </Table.Cell>
      {showRoles && (
        <Table.Cell
          color="label"
          style={{
            verticalAlign: 'middle',
          }}
        >
          {gear.allowed_roles && gear.allowed_roles.length > 0 ? (
            gear.allowed_roles.length === 1 ? (
              gear.allowed_roles[0]
            ) : (
              <Tooltip content={gear.allowed_roles.join(', ')}>
                <Box
                  inline
                  style={{
                    borderBottom: '1px dotted #909090',
                    paddingBottom: '1px',
                  }}
                >
                  {gear.allowed_roles[0]}, {gear.allowed_roles[1][0]}...
                </Box>
              </Tooltip>
            )
          ) : null}
        </Table.Cell>
      )}
      {selectedCategory !== 'Donator' && (
        <Table.Cell
          collapsing
          textAlign="center"
          style={{
            verticalAlign: 'middle',
          }}
        >
          {gear.cost.toLocaleString()}
        </Table.Cell>
      )}
      <Table.Cell
        textAlign="center"
        style={{
          verticalAlign: 'middle',
        }}
      >
        <Button
          disabled={
            (!isPurchased(purchased_gear, gear) &&
              gear.cost > metacurrency_balance) ||
            (gear.donator && !is_donator) ||
            (isPurchased(purchased_gear, gear) &&
              !gear.is_equippable &&
              !gear.multi_purchase)
          }
          tooltip={
            !isPurchased(purchased_gear, gear) &&
            gear.cost > metacurrency_balance
              ? 'Not Enough ' + metacurrency_name + 's!'
              : null
          }
          content={
            isPurchased(purchased_gear, gear)
              ? equipped_gear.includes(gear.id)
                ? 'Unequip'
                : !gear.is_equippable
                  ? 'Purchased'
                  : 'Equip'
              : 'Purchase'
          }
          onClick={() =>
            act(
              isPurchased(purchased_gear, gear)
                ? 'equip_gear'
                : 'purchase_gear',
              {
                id: gear.id,
              },
            )
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};
