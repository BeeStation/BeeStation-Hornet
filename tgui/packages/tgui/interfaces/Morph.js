import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Section, Tabs, LabeledList } from '../components';

export const Morph = (props, context) => {
  return (
    <Window theme="generic" width={650} height={650}>
      <Window.Content scrollable>
        <MorphContents />
      </Window.Content>
    </Window>
  );
};

const MorphContents = (props, context) => {
  const { data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'living');
  const favorites = Object.values(data.contents.living)
    .concat(Object.values(data.contents.items))
    .filter((A) => A.favorite);
  return (
    <Section title="Morph Stomach">
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
          favorites.map((A) => <MorphItem key={A.id} throw_ref={data.throw_ref} {...A} />)
        ) : data.contents[tab] ? (
          Object.values(data.contents[tab]).map((A) => <MorphItem key={A.id} throw_ref={data.throw_ref} {...A} />)
        ) : (
          <span>
            <strong>Your stomach is empty!</strong>
          </span>
        )}
      </LabeledList>
    </Section>
  );
};

const MorphItem = ({ name, id, img, living, favorite, digestable, throw_ref }, context) => {
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
