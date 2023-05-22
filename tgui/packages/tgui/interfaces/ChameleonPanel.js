import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { resolveAsset } from '../assets';
import { Window } from '../layouts';
import {
  Button,
  Box,
  Stack,
  Section,
  Icon,
  Input,
  Flex,
  Tabs,
  Tooltip,
} from '../components';
import { createSearch } from 'common/string';

export const ChameleonPanel = (_, context) => {
  const { act, data } = useBackend(context);
  const { manual } = data;
  const [compact, setCompact] = useLocalState(context, 'compact', false);
  const [tab] = useLocalState(context, 'tab', 1);
  return (
    <Window
      title="Chameleon Panel"
      theme="generic"
      width={900}
      height={700}
      buttons={
        <>
          {!!manual.can_craft && (
            <Button
              content={
                manual.cooldown > 0
                  ? `Create Manual (in ${manual.cooldown}s)`
                  : 'Create Manual'
              }
              disabled={manual.cooldown > 0}
              icon="book"
              m={1}
              onClick={() => act('create_manual')}
            />
          )}
          <Button.Checkbox
            checked={compact} // jerma985
            content="List Mode"
            icon="list"
            m={1}
            onClick={() => setCompact(!compact)}
          />
        </>
      }>
      <Window.Content scrollable>
        <ChameleonPanelTabs />
        {tab === 1 && <DisguisePanel />}
        {tab === 2 && <OutfitsPanel />}
      </Window.Content>
    </Window>
  );
};

const ChameleonIcon = (props, _) => {
  const { assetName, assetClass } = props;
  if (assetName) {
    return (
      <img
        src={resolveAsset(assetName)}
        style={{
          'vertical-align': 'middle',
          'horizontal-align': 'middle',
          'width': '64px',
          'height': '64px',
        }}
      />
    );
  } else if (assetClass) {
    return (
      <span
        className={classes(['chameleon64x64', assetClass])}
        style={{
          'vertical-align': 'middle',
          'horizontal-align': 'middle',
        }}
      />
    );
  } else {
    return <Box />;
  }
};

const ChameleonPanelTabs = (_, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', 1);
  return (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={tab === 1}
        lineHeight="24px"
        onClick={() => setTab(1)}>
        Chameleon Editor
      </Tabs.Tab>
      <Tabs.Tab
        icon="user"
        selected={tab === 2}
        lineHeight="24px"
        onClick={() => setTab(2)}>
        Outfits
      </Tabs.Tab>
    </Tabs>
  );
};

const OutfitsPanel = (_, context) => {
  const [compact] = useLocalState(context, 'compact', false);
  const { data } = useBackend(context);
  const { outfits } = data;
  const [searchText, setSearchText] = useLocalState(
    context,
    'outfitsSearchText',
    ''
  );
  const search = createSearch(searchText, (item) => {
    return item.name;
  });
  const outfits_filtered = outfits
    ? searchText.length > 0
      ? outfits.filter(search)
      : outfits
    : [];
  return (
    <Section
      title="Outfits"
      buttons={
        <Flex>
          <Flex.Item>
            <Icon
              name="search"
              mr={1} />
          </Flex.Item>
          <Flex.Item grow={1}>
            <Input
              placeholder="Search..."
              fluid
              value={searchText}
              onInput={(_, value) => setSearchText(value)} />
          </Flex.Item>
        </Flex>
      }>
      <Stack fill>
        <Stack.Item grow>
          {(compact && <OutfitsCompact outfits={outfits_filtered} />) || (
            <Outfits outfits={outfits_filtered} />
          )}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const OutfitsCompact = (props, context) => {
  const { outfits } = props;
  const { act, data } = useBackend(context);
  const { icons } = data;
  return outfits.map((outfit, _) => {
    const outfit_icon = icons['outfits'][outfit.type];
    return (
      <Flex key={outfit.type} justify="space-between" className="candystripe">
        <Flex.Item m={0.5}>{outfit.name}</Flex.Item>
        <Flex.Item m={0.5}>
          <Tooltip
            content={<ChameleonIcon assetName={outfit_icon} />}
            position="left">
            <Button
              onClick={() => act('equip_outfit', { outfit: outfit.type })}>
              Disguise
            </Button>
          </Tooltip>
        </Flex.Item>
      </Flex>
    );
  });
};

const Outfits = (props, context) => {
  const { outfits } = props;
  const { act, data } = useBackend(context);
  const { icons } = data;
  return outfits.map((outfit, _) => {
    const outfit_icon = icons['outfits'][outfit.type];
    return (
      <Flex inline direction="column" width="80px" key={outfit.type}>
        <Flex.Item>
          <Button
            key={outfit.type}
            onClick={() => act('equip_outfit', { outfit: outfit.type })}>
            <ChameleonIcon assetName={outfit_icon} />
          </Button>
        </Flex.Item>
        <Flex.Item textAlign="center" fontSize="10px" style={{ "overflow-wrap": "anywhere" }}>
          {outfit.name}
        </Flex.Item>
      </Flex>
    );
  });
};

const ExtraActions = (props, context) => {
  const { act } = useBackend(context);
  const { actions, itemRef } = props;
  return actions.map((action_name, _) => {
    return (
      <Stack.Item key={action_name}>
        <Button
          onClick={() => {
            act('extra_action', {
              ref: itemRef,
              action: action_name,
            });
          }}>
          {action_name}
        </Button>
      </Stack.Item>
    );
  });
};

const DisguisePanel = (_, context) => {
  const { act, data } = useBackend(context);
  const { chameleon_items } = data;
  const [compact] = useLocalState(context, 'compact', false);
  const [searchText, setSearchText] = useLocalState(
    context,
    'disguiseSearchText',
    ''
  );
  const search = createSearch(searchText, (item) => {
    return item.name;
  });
  const [selected] = useLocalState(context, 'selected');
  const selectedChameleon = chameleon_items.find(
    (chameleon) => chameleon.ref === selected
  );
  const disguises = selectedChameleon
    ? searchText.length > 0
      ? selectedChameleon.disguises.filter(search)
      : selectedChameleon.disguises
    : [];
  return (
    <Stack>
      <Stack.Item>
        <DisguiseItems />
      </Stack.Item>
      <Stack.Item grow>
        <Section
          grow
          title="Disguises"
          buttons={
            <Stack>
              {!!selectedChameleon && (
                <ExtraActions
                  actions={selectedChameleon.extra_actions}
                  itemRef={selectedChameleon.ref}
                />
              )}
              <Stack.Item>
                <Flex>
                  <Flex.Item>
                    <Icon
                      name="search"
                      mr={1} />
                  </Flex.Item>
                  <Flex.Item>
                    <Input
                      placeholder="Search..."
                      fluid
                      width="200px"
                      value={searchText}
                      onInput={(_, value) => setSearchText(value)} />
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            </Stack>
          }>
          {(!!compact && (
            <DisguisesCompact
              selectedChameleon={selectedChameleon}
              disguises={disguises}
            />
          )) || (
            <Disguises
              selectedChameleon={selectedChameleon}
              disguises={disguises}
            />
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DisguiseItems = (_, context) => {
  const { data } = useBackend(context);
  const { chameleon_items } = data;
  const [selected, setSelected] = useLocalState(context, 'selected');
  return (
    <Stack vertical fill>
      {chameleon_items.map((disguise, _) => {
        const disguise_icon = disguise.type
          .replace('/obj/item/', '')
          .replace(/\//g, '-');
        return (
          <Stack.Item key={disguise.ref}>
            <Flex direction="column" width="80px">
              <Flex.Item>
                <Button
                  key={disguise.ref}
                  selected={selected === disguise.ref}
                  tooltip={disguise.slot}
                  onClick={() => setSelected(disguise.ref)}>
                  <ChameleonIcon assetClass={disguise_icon} />
                </Button>
              </Flex.Item>
              <Flex.Item textAlign="center" fontSize="10px">
                {disguise.name}
              </Flex.Item>
            </Flex>
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

const Disguises = (props, context) => {
  const { disguises, selectedChameleon } = props;
  const { act } = useBackend(context);
  return (disguises || []).map((disguise, _) => {
    const disguise_icon = disguise.type
      .replace('/obj/item/', '')
      .replace(/\//g, '-');
    return (
      <Flex inline direction="column" width="80px" key={disguise.type}>
        <Flex.Item>
          <Button
            selected={selectedChameleon.current_disguise === disguise.type}
            tooltip={disguise.icon_name}
            onClick={() =>
              act('disguise', {
                ref: selectedChameleon.ref,
                type: disguise.type,
              })}>
            <ChameleonIcon assetClass={disguise_icon} />
          </Button>
        </Flex.Item>
        <Flex.Item textAlign="center" fontSize="10px" style={{ "overflow-wrap": "anywhere" }}>
          {`${disguise.name}`}
        </Flex.Item>
      </Flex>
    );
  });
};

const DisguisesCompact = (props, context) => {
  const { disguises, selectedChameleon } = props;
  const { act } = useBackend(context);
  return (disguises || []).map((disguise, _) => {
    const disguise_icon = disguise.type
      .replace('/obj/item/', '')
      .replace(/\//g, '-');
    return (
      <Flex key={disguise.type} justify="space-between" className="candystripe">
        <Flex.Item m={0.5}>
          {`${disguise.name} (${disguise.icon_name})`}
        </Flex.Item>
        <Flex.Item m={0.5}>
          <Tooltip
            content={<ChameleonIcon assetClass={disguise_icon} />}
            position="left">
            <Button
              selected={selectedChameleon.current_disguise === disguise.type}
              onClick={() =>
                act('disguise', {
                  ref: selectedChameleon.ref,
                  type: disguise.type,
                })}>
              {selectedChameleon.current_disguise === disguise.type
                ? 'Disguised'
                : 'Disguise'}
            </Button>
          </Tooltip>
        </Flex.Item>
      </Flex>
    );
  });
};
