import { Box, Tabs, Button, Section, Stack, Flex, Table } from '../../components';
import { PreferencesMenuData } from './data';
import { useBackend, useLocalState } from '../../backend';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';
import { CharacterPreview } from './CharacterPreview';

export const LoadoutPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const { purchased_gear = [], equipped_gear = [], character_preferences, metacurrency_balance = 0, is_donator = false } = data;
  const jumpsuit_style = character_preferences.clothing.jumpsuit_style;
  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading loadout data...</Box>;
        }
        const { categories = [], metacurrency_name } = serverData.loadout;
        const [selectedCategory, setSelectedCategory] = useLocalState(context, 'category', categories[0].name);

        let selectedCategoryObject = categories.filter((c) => c.name === selectedCategory)[0];

        return (
          <Stack height="100%">
            <Stack.Item>
              <Flex
                width="219px"
                mb={1}
                p={1}
                fontSize="22px"
                style={{ 'align-items': 'center' }}
                className="section-background">
                <Flex.Item>
                  <Button icon="undo" tooltip="Rotate" tooltipPosition="top" onClick={() => act('rotate')} />
                </Flex.Item>
                <Flex.Item grow textAlign="center">
                  {metacurrency_balance} {metacurrency_name}
                </Flex.Item>
              </Flex>
              <CharacterPreview height="calc(100vh - 170px)" id={data.character_preview_view} />
            </Stack.Item>
            <Stack.Item grow height="100%">
              <Flex direction="column" height="100%">
                <Flex.Item>
                  <Tabs>
                    {categories
                      .filter((c) => c.name !== 'Donator' || is_donator)
                      .map((category) => (
                        <Tabs.Tab
                          key={category.name}
                          textAlign="center"
                          selected={selectedCategory === category.name}
                          onClick={() => setSelectedCategory(category.name)}>
                          {category.name}
                        </Tabs.Tab>
                      ))}
                  </Tabs>
                </Flex.Item>
                <Flex.Item grow basis="content" height="0">
                  <Box
                    width="100%"
                    height="100%"
                    className="section-background"
                    style={{ padding: '0.66em 0.5em', 'overflow-y': 'scroll' }}>
                    <Table>
                      <Table.Row header>
                        <Table.Cell collapsing />
                        <Table.Cell>Name</Table.Cell>
                        {selectedCategory !== 'Donator' && (
                          <Table.Cell collapsing textAlign="center">
                            Cost
                          </Table.Cell>
                        )}
                        <Table.Cell style={{ 'min-width': '7rem' }} collapsing />
                      </Table.Row>
                      {selectedCategoryObject &&
                        selectedCategoryObject.gear.map((gear) => (
                          <Table.Row key={gear.id}>
                            <Table.Cell m={0} p={0}>
                              <Box
                                inline
                                className={`preferences_loadout32x32 loadout_gear___${gear.id}${
                                  jumpsuit_style === 'Jumpskirt' && gear.skirt_display_name ? '_skirt' : ''
                                }`}
                                style={{
                                  'vertical-align': 'middle',
                                  'horizontal-align': 'middle',
                                }}
                              />
                            </Table.Cell>
                            <Table.Cell style={{ 'vertical-align': 'middle' }}>
                              {jumpsuit_style === 'Jumpskirt' && gear.skirt_display_name
                                ? gear.skirt_display_name
                                : gear.display_name}
                            </Table.Cell>
                            {!gear.donator && <Table.Cell textAlign="center">{gear.cost}</Table.Cell>}
                            <Table.Cell textAlign="center">
                              <Button
                                content={
                                  purchased_gear.includes(gear.id)
                                    ? equipped_gear.includes(gear.id)
                                      ? 'Unequip'
                                      : 'Equip'
                                    : 'Purchase'
                                }
                                onClick={() =>
                                  act(purchased_gear.includes(gear.id) ? 'equip_gear' : 'purchase_gear', {
                                    id: gear.id,
                                  })
                                }
                              />
                            </Table.Cell>
                          </Table.Row>
                        ))}
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
