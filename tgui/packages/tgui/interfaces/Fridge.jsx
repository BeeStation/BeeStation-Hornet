import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Input, Button, Section, Tabs, LabeledList, Box, Flex, Icon } from '../components';

export const Fridge = () => {
  return (
    <Window theme="ntos" width={650} height={650}>
      <Window.Content scrollable>
        <FridgeContents />
      </Window.Content>
    </Window>
  );
};

const FridgeContents = (_props) => {
  const { data } = useBackend();
  const [tab, setTab] = useLocalState('tab', 'living');
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const fruits = Object.values(data.contents.fruits);
  const vegetables = Object.values(data.contents.vegetables);
  const misc = Object.values(data.contents.misc)
    .concat(Object.values(data.contents.items))
    .filter((A) => A.favorite);
  const fridgesearch = createSearch(searchText, (item) => {
    return item.name;
  });
  return (
    <Section
      title="Fridge Contents"
      buttons={
        <>
          <Flex color="black" backgroundColor="white" style={{ padding: '2px 2px 0 2px' }}>
            <Flex.Item align="center" grow={1}>
              <Box align="center">{item}</Box>
            </Flex.Item>
            <Flex.Item>
              {<Button icon="search" onClick={() => act('examine', { ref: contents_ref[index] })} />}
              <Button icon="eject" onClick={() => act('remove', { ref: contents_ref[index] })} />
            </Flex.Item>
          </Flex>
          <Box inline>
            <Icon name="search" mr={1} />
          </Box>
          <Box inline>
            <Input placeholder="Search..." width="200px" value={searchText} onInput={(_, value) => setSearchText(value)} />
          </Box>
        </>
      }>
      <Tabs>
        <Tabs.Tab selected={tab === 'Misc'} onClick={() => setTab('Misc')}>
          Misc ({Object.keys(data.contents.living).length})
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 'Fruits'} onClick={() => setTab('Fruits')}>
          Fruits ({Object.keys(data.contents.items).length})
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 'Vegetables'} onClick={() => setTab('Vegetables')}>
          Vegetables ({Object.keys(data.contents.items).length})
        </Tabs.Tab>
      </Tabs>
    </Section>
  );
};
