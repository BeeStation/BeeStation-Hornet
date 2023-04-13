import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { resolveAsset } from '../assets';
import { Window } from '../layouts';
import {
  Button,
  Stack,
  Section,
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
        {tab === 3 && <PresetsPanel />}
      </Window.Content>
    </Window>
  );
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
      <Tabs.Tab
        icon="address-book"
        selected={tab === 3}
        lineHeight="24px"
        onClick={() => setTab(3)}>
        Custom Presets
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
        <>
          Search
          <Input
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
            mx={1}
          />
        </>
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
            content={
              !!outfit_icon && (
                <img
                  src={resolveAsset(outfit_icon)}
                  style={{
                    'vertical-align': 'middle',
                    'horizontal-align': 'middle',
                    'width': '64px',
                    'height': '64px',
                  }}
                />
              )
            }
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
      <Button
        key={outfit.type}
        tooltip={outfit.name}
        onClick={() => act('equip_outfit', { outfit: outfit.type })}>
        {!!outfit_icon && (
          <img
            src={resolveAsset(outfit_icon)}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
              'width': '64px',
              'height': '64px',
            }}
          />
        )}
      </Button>
    );
  });
};

const PresetsPanel = (_, context) => {
  const { act } = useBackend(context);
  const [compact] = useLocalState(context, 'compact', false);
  return (
    <Section
      grow
      title="Disguises"
      buttons={
        <Button
          onClick={() => {
            act('save_preset');
          }}>
          Create Preset
        </Button>
      }>
      <Stack fill>
        <Stack.Item grow>
          {(compact && <PresetsCompact />) || <Presets />}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Presets = (_, context) => {
  const { data } = useBackend(context);
  const { presets } = data;
  return (presets || []).map((preset, _) => {});
};

const PresetsCompact = (_, context) => {
  const { act, data } = useBackend(context);
  const { presets } = data;
  return (presets || []).map((preset, _) => {
    // const preset_icon = icons['presets'][preset.name];
    return (
      <Flex key={preset.name} justify="space-between" className="candystripe">
        <Flex.Item m={0.5}>{preset.name}</Flex.Item>
        <Flex.Item m={0.5}>
          <Tooltip position="left">
            <Button onClick={() => act('load_preset', { preset: preset.name })}>
              Disguise
            </Button>
            <Button
              onClick={() => act('delete_preset', { preset: preset.name })}>
              Delete
            </Button>
          </Tooltip>
        </Flex.Item>
      </Flex>
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
            <Flex>
              {!!selectedChameleon &&
                selectedChameleon.extra_actions.map((action_name, _) => {
                  return (
                    <Flex.Item key={action_name}>
                      <Button
                        onClick={() => {
                          act('extra_action', {
                            ref: selectedChameleon.ref,
                            action: action_name,
                          });
                        }}>
                        {action_name}
                      </Button>
                    </Flex.Item>
                  );
                })}
              <Flex.Item>
                Search
                <Input
                  value={searchText}
                  onInput={(_, value) => setSearchText(value)}
                  mx={1}
                />
              </Flex.Item>
            </Flex>
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
            <Button
              key={disguise.ref}
              tooltip={disguise.name}
              selected={selected === disguise.ref}
              onClick={() => setSelected(disguise.ref)}>
              <span
                className={classes(['chameleon64x64', disguise_icon])}
                style={{
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle',
                }}
              />
            </Button>
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
      <Button
        key={disguise.type}
        tooltip={`${disguise.name} (${disguise.icon_name})`}
        selected={selectedChameleon.current_disguise === disguise.type}
        m={1}
        onClick={() =>
          act('disguise', {
            ref: selectedChameleon.ref,
            type: disguise.type,
          })
        }>
        <span
          className={classes(['chameleon64x64', disguise_icon])}
          style={{
            'vertical-align': 'middle',
            'horizontal-align': 'middle',
          }}
        />
      </Button>
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
            content={
              <span
                className={classes(['chameleon64x64', disguise_icon])}
                style={{
                  'vertical-align': 'middle',
                  'horizontal-align': 'middle',
                }}
              />
            }
            position="left">
            <Button
              selected={selectedChameleon.current_disguise === disguise.type}
              onClick={() =>
                act('disguise', {
                  ref: selectedChameleon.ref,
                  type: disguise.type,
                })
              }>
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
