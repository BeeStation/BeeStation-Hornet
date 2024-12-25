import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Input, Button, Section, Tabs, LabeledList, Box, Icon } from '../components';

export const Morph = () => {
  return (
    <Window theme="generic" width={650} height={650}>
      <Window.Content scrollable>
        <MorphContents />
      </Window.Content>
    </Window>
  );
};

const MorphContents = (_props, context) => {
  const { data } = useBackend(context);
  const [tab, setTab] = useLocalState(context, 'tab', 'living');
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const favorites = Object.values(data.contents.living)
    .concat(Object.values(data.contents.items))
    .filter((A) => A.favorite);
  const stomachSearch = createSearch(searchText, (item) => {
    return item.name;
  });
  return (
    <Section
      title="Morph Stomach"
      buttons={
        <>
          <Box inline>
            <Icon name="search" mr={1} />
          </Box>
          <Box inline>
            <Input placeholder="Search..." width="200px" value={searchText} onInput={(_, value) => setSearchText(value)} />
          </Box>
        </>
      }>
      <Tabs>
        <Tabs.Tab selected={tab === 'living'} onClick={() => setTab('living')}>
          Mobs ({Object.keys(data.contents.living).length})
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 'items'} onClick={() => setTab('items')}>
          Items ({Object.keys(data.contents.items).length})
        </Tabs.Tab>
        <Tabs.Tab selected={tab === 'favorites'} onClick={() => setTab('favorites')}>
          Favorites ({favorites.length})
        </Tabs.Tab>
      </Tabs>
      <LabeledList>
        {tab === 'favorites' ? (
          favorites.filter(stomachSearch).map((A) => <MorphItem key={A.id} throw_ref={data.throw_ref} {...A} />)
        ) : data.contents[tab] ? (
          Object.values(data.contents[tab])
            .filter(stomachSearch)
            .map((A) => <MorphItem key={A.id} throw_ref={data.throw_ref} {...A} />)
        ) : (
          <span>
            <strong>Your stomach is empty!</strong>
          </span>
        )}
      </LabeledList>
    </Section>
  );
};

const MorphItem = ({ name, id, img, living, favorite, digestable, throw_ref }) => {
  return (
    <LabeledList.Item
      label={
        <>
          {img ? (
            <img
              src={`data:image/jpeg;base64,${img}`}
              style={{
                'vertical-align': 'middle',
                'horizontal-align': 'middle',
              }}
            />
          ) : null}
          <span title={name}>{name.length > 26 ? name.substring(0, 24) + '...' : name}</span>
        </>
      }>
      <MorphItemButtons {...{ id, living, favorite, digestable, throw_ref }} />
    </LabeledList.Item>
  );
};

const MorphItemButtons = ({ id, living, favorite, digestable, throw_ref }, context) => {
  const { act } = useBackend(context);
  return (
    <>
      <Button
        color={favorite ? 'yellow' : null}
        icon={favorite ? 'star' : 'star-o'}
        onClick={() => act('favorite', { id: id })}
      />
      <Button content="Disguise As" onClick={() => act('disguise', { id: id })} />
      <Button content="Drop" onClick={() => act('drop', { id: id })} />
      <Button content="Digest" disabled={!digestable} onClick={() => act('digest', { id: id })} />
      <Button
        content={throw_ref === id ? 'Unthrow' : 'Throw'}
        onClick={() => act(throw_ref === id ? 'unthrow' : 'throw', { id: id })}
      />
      {living ? null : (
        <>
          <Button content="Use" onClick={() => act('use', { id: id })} />
          <Button content="Use and Throw" disabled={throw_ref === id} onClick={() => act('usethrow', { id: id })} />
        </>
      )}
    </>
  );
};
